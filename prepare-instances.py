#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" This script creates Postgres instances specified in a configuration xml.
"""

# pylint: disable=invalid-name

# Requirements: docker, bash, wget, git, tar

import sys
import os
import xml.etree.ElementTree
import xml.etree.ElementInclude
from subprocess import check_call, check_output
import re
import argparse

# Remove all docker containers
# check_call('for dc in $(docker ps -aq); do docker rm --force $dc; done',
#            shell=True)


def main(configfile, instances):
    """
    Main function to create the passed-in instances using the specified
    configuration.
    """
    # pylint: disable=too-many-locals,too-many-branches,too-many-statements

    def get_os_property(instance, prop):
        if instance.find('os') is not None and \
           prop in instance.find('os').attrib:
            return instance.find('os').get(prop)
        return config.find('./settings/default/os').get(prop)

    def get_repo_url(instance):
        if instance.get('repository') is None:
            repo_id = config.find('./settings/default/repository').get('id')
        else:
            repo_id = instance.get('repository')
        repo = config.find(f'./settings//repositories/repository'
                           f'[@id="{repo_id}"]')
        repo_url = repo.get('url') if repo is not None else None
        if repo_url:
            if instance.get('pgpro_edition') is not None:
                repo_url = re.sub(r'\$PGPRO_EDN\b',
                                  instance.get('pgpro_edition'), repo_url)
            if instance.get('pg_version') is not None:
                repo_url = re.sub(r'\$PG_VERSION\b',
                                  instance.get('pg_version'), repo_url)
            return repo_url
        return None

    config = xml.etree.ElementTree.parse(configfile).getroot()
    try:
        xml.etree.ElementInclude.include(config)
    except FileNotFoundError:
        pass

    for instance in config.findall('./pg_instances//instance'):
        instance_id = instance.get('id')
        if len(instances) > 0:
            if instance_id not in instances:
                continue
        elif instance.get('disabled') == 'true':
            continue
        print(f'Instance {instance_id} creating...')
        build_args = []

        check_call(f'for di in $(docker images -aq {instance.get("id")}); do'
                   f' docker rmi $di; done', shell=True)
        check_call('for dv in $(docker volume ls -q -f dangling=true); do'
                   ' docker volume rm $dv; done', shell=True)

        check_call('rm -rf docker-context; mkdir docker-context && '
                   'cp -R context-template/* docker-context/', shell=True)

        if instance.get('type') == 'src':
            #  Prepare source directory
            git_dir = config.find('./settings/default/git').get('path')
            if not os.path.exists(git_dir):
                raise Exception(f'Git directory ({git_dir}) not found'
                                ' (check settings/default/git in config.xml)!')
            git_branch = instance.get('git_branch')
            if git_branch:
                check_call(f'cd "{git_dir}" && git checkout "{git_branch}" && '
                           f'rm -rf * && git reset --hard HEAD && git rebase',
                           shell=True)

            git_commit = instance.get('git_commit')
            if git_commit:
                check_call(f'cd "{git_dir}" && git checkout "{git_commit}" && '
                           f'git reset --hard HEAD',
                           shell=True)

            for patch in instance.findall('patches/patch'):
                if patch.get('commit'):
                    check_call(f'cd "{git_dir}" && git apply ' +
                               patch.get("commit"),
                               shell=True)
                elif patch.get('file'):
                    check_call(f'cd "{git_dir}" && patch -p1 -l -i ' +
                               os.path.abspath(patch.get("file")),
                               shell=True)

            extra_version = check_output(
                f'cd "{git_dir}" && echo `git rev-parse --abbrev-ref HEAD`/'
                f'`git rev-parse --short HEAD`', shell=True).\
                decode('utf-8').strip()

            check_call(f'cd "{git_dir}" && tar --exclude=.git -czf '
                       f'../docker-context/postgres.tar.gz *', shell=True)

            cfg_options = ''
            if extra_version:
                cfg_options += f' --with-extra-version=-{extra_version} '
            if instance.get('cfg_options') is not None:
                cfg_options += instance.get('cfg_options')
            if cfg_options:
                build_args += ['--build-arg', (f'CFG_OPTIONS="{cfg_options}"')]

        # Prepare reference pgbench
        git_dir = config.find('./settings/default/git').get('path')
        ref_pgbench_version = 'REL_11_1'
        check_call(f'cd "{git_dir}" && rm -rf * && '
                   f'git checkout {ref_pgbench_version} >/dev/null && '
                   f'git reset --hard HEAD >/dev/null',
                   shell=True)
        check_call(f'cd "{git_dir}" && tar --exclude=.git --exclude=doc -czf '
                   f'../docker-context/postgres-pgbench.tar.gz *',
                   shell=True)

        with open('Dockerfile-' + instance.get('type'), 'r',
                  encoding='UTF-8') as dockerfile:
            df_contents = dockerfile.read()
        df_contents = re.sub(r'^FROM ubuntu\b',
                             ('FROM ubuntu:' +
                              get_os_property(instance, 'version')),
                             df_contents)
        with open('docker-context/Dockerfile', 'w',
                  encoding='UTF-8') as dockerfile:
            dockerfile.write(df_contents)

        if instance.get('pg_version') is not None:
            build_args += ['--build-arg', ('PG_VERSION=' +
                                           instance.get('pg_version'))]
        if instance.get('pgpro_edition') is not None:
            build_args += ['--build-arg', ('PGPRO_EDN=' +
                                           instance.get('pgpro_edition'))]
        pg_params = ''
        for param in instance.findall('config/pg_param'):
            pg_params += f"{param.get('name')} = '{param.get('value')}'\\n"
        if pg_params:
            build_args += ['--build-arg',
                           (f'PG_PARAMETERS="{pg_params}"')]

        repo_url = get_repo_url(instance)
        if repo_url is not None:
            build_args += ['--build-arg', ('REPOSITORY=' + repo_url)]

        extra = instance.find('extra')
        if extra is not None:
            if extra.find('source') is not None and \
               extra.find('source').get('type') == 'git':
                extra_git_url = extra.find('source').get('url')
                build_args += ['--build-arg', ('EXTRA_SRC_GIT=' +
                                               extra_git_url)]
            pg_modules = ''
            for pgm in extra.findall('pg_module'):
                pg_modules += (',' if pg_modules else '') + pgm.get('name')
            build_args += ['--build-arg',
                           (f'EXTRA_PG_MODULES="{pg_modules}"')]

        extra_os_packages = ''
        phase1_action = 'nop'
        phase2_action = 'nop'
        if instance.find('os') is not None:
            if instance.find('os').get('phase1_action') is not None:
                phase1_action = instance.find('os').get('phase1_action')
            if instance.find('os').get('phase2_action') is not None:
                phase2_action = instance.find('os').get('phase2_action')
            if instance.find('os').get('extra_packages') is not None:
                extra_os_packages = instance.find('os').get('extra_packages')
        build_args += ['--build-arg', ('PHASE1_ACTION=' + phase1_action)]
        build_args += ['--build-arg', ('PHASE2_ACTION=' + phase2_action)]
        build_args += ['--build-arg',
                       (f'EXTRA_OS_PACKAGES="{extra_os_packages}"')]

        check_call(['docker', 'build'] + build_args +
                   ['-t', instance.get('id'), 'docker-context'])


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('-c', '--config', action='store',
                            default='config.xml', help='configuration file')
    arg_parser.add_argument('-i', '--instance', nargs='+',
                            dest='instances', metavar='INSTANCE-ID',
                            default=[], help='instance(s) to create')

    args = arg_parser.parse_args(sys.argv[1:])
    sys.exit(main(args.config, args.instances))
