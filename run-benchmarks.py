#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This script runs benchmarks on Postgres instances
as specified in a configuration file.
"""

# pylint: disable=invalid-name,broad-exception-raised

# Requirements: docker, bash, wget, git, tar, 7z

import os
import sys
from xml.etree.ElementTree import Element, SubElement, ElementTree
import xml.etree.ElementInclude
import subprocess
from subprocess import run
from time import sleep
import datetime
import re
import argparse
import shutil
import tempfile

verbose = False


def prepare_prerequisite(url, res_type, setup, target_dir):
    """
    The function to prepare prerequisites for running benchmarks.
    """

    if os.path.exists(target_dir):
        return
    if url is None:
        raise Exception(f'Source url for "{target_dir}" is undefined.')
    if url[0] == '#':
        raise Exception(f'Target directory "{target_dir}" does not exist. '
                        f'Download the prerequisite from {url[1:]} and '
                        f'unpack it to the directory manually.')
    print(f'\tPreparing prerequisite {target_dir}')
    os.makedirs(target_dir)
    try:
        if res_type == 'tar':
            res = run(f'wget -nv -O- "{url}" | '
                      f'tar xvz -C {target_dir} >/dev/null && '
                      f'chmod -R 755 {target_dir}',
                      shell=True, check=False, stdout=subprocess.PIPE)
        elif res_type == 'zip':
            res = run(f'wget -nv "{url}" -O /tmp/t.zip && '
                      f'$(which 7z || which 7za || echo 7z-missing)'
                      f' x /tmp/t.zip -o{target_dir} >/dev/null && '
                      f'chmod -R 755 {target_dir} && rm /tmp/t.zip',
                      shell=True, check=False, stdout=subprocess.PIPE)
        elif res_type == 'git':
            res = run(f'git clone {url} {target_dir}',
                      shell=True, check=False, stdout=subprocess.PIPE)
        else:
            raise Exception(f'Invalid prerequisite type ({res_type}).')
        if res.returncode != 0:
            print(res.stdout.decode('utf-8'))
            raise Exception(f'Getting prerequisite "{target_dir}" failed!')
        if setup is not None:
            res = run(f'{setup} {target_dir}',
                      shell=True, check=False, stdout=subprocess.PIPE)
            if res.returncode != 0:
                print(res.stdout.decode('utf-8'))
                raise Exception(f'Running setup command "{setup}" failed!')
    except Exception as ex:
        shutil.rmtree(target_dir)
        raise ex


def main(configfile, instances, benchmarks, resultsfile, resultsdir):
    """
    Main function to run specified benchmarks.
    """
    # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    # pylint: disable=too-many-nested-blocks

    config = ElementTree(None, configfile).getroot()
    try:
        xml.etree.ElementInclude.include(config)
    except FileNotFoundError:
        pass

    try:
        restop = xml.etree.ElementTree.parse(resultsfile).getroot()
    except FileNotFoundError:
        restop = Element('benchmarking')
    bmrun = SubElement(restop, 'run')
    bmrun.set('started', datetime.datetime.now().
              replace(microsecond=0).isoformat())
    bmrun_id = bmrun.get('started')
    if not os.path.exists(os.getcwd() + '/resources'):
        os.makedirs(os.getcwd() + '/resources')
    if not os.path.exists(resultsdir):
        os.makedirs(resultsdir)
    soft_reset = (os.getcwd() + '/scripts/soft-reset') if \
        os.path.exists(os.getcwd() + '/scripts/soft-reset') else None
    if soft_reset:
        print('The soft-reset utility found -- '
              'it will be executed before each run.')

    insts = {}
    if not instances:
        for inst in config.findall('./pg_instances//instance'):
            if inst.get('disabled') == 'true':
                continue
            insts[inst.get('id')] = inst
    else:
        inst_cnts = {}
        for i in instances:
            if i not in inst_cnts:
                inst_cnts[i] = 1
            else:
                inst_cnts[i] += 1
            xi = config.find(f'./pg_instances//instance[@id="{i}"]')
            if xi is None:
                raise Exception(f'Invalid instance id: {i}.')
            insts[f'{i}--{inst_cnts[i]}'] = xi

    benches = []
    if len(benchmarks) > 0:
        for b in benchmarks:
            xb = config.find(f'./benchmarks/benchmark[@id="{b}"]')
            if xb is None:
                raise Exception(f'Invalid benchmark id: {b}.')
            benches.append(xb)
    else:
        for xb in config.findall('./benchmarks/benchmark'):
            if xb.get('disabled') == 'true':
                continue
            benches.append(xb)

    for bench in benches:
        bench_id = bench.get('id')
        print(f'Benchmark "{bench_id}".')

        for preq in bench.findall('prerequisites/*'):
            prepare_prerequisite(preq.get('url'), preq.tag,
                                 preq.get('setup'), preq.get('target_dir'))

        pg_params = ''
        for param in bench.findall('config/pg_param'):
            pg_params += f"{param.get('name')} = '{param.get('value')}'\n"
        prepare = None
        prepare_node = bench.find('prepare')
        if prepare_node is not None:
            prepare = prepare_node.text.strip()
        execute_node = bench.find('execute')
        if execute_node is None:
            continue
        execute = execute_node.text.strip()
        bmbench = SubElement(bmrun, 'benchmark')
        bmbench.set('id', bench_id)
        for instance_uid, instance in insts.items():
            instance_id = instance.get('id')

            if re.match(r'^[\./]', instance_id):
                raise Exception(f'Invalid image id: {instance_id}')
            print(f'Benchmarking {instance_id}...')

            if soft_reset:
                if verbose:
                    print('\tPerforming soft reset...')
                res = run(soft_reset, shell=False, check=False,
                          stdout=subprocess.PIPE)
                if verbose:
                    print('\tSoft reset finished.')
                if res.returncode != 0:
                    print(res.stdout.decode('utf-8'))
                    raise Exception(f'Soft reset failed '
                                    f'(exit code: {res.returncode})!')

            envvars = ''
            for envvar in instance.findall('config/envvar'):
                envvars += ' -e ' + (envvar.get('name') + '=' +
                                     envvar.get('value'))
            resultdir = os.path.abspath(
                f'{resultsdir}/run-{bmrun_id.replace(":", "-")}/{bench_id}/'
                f'{instance_uid}')
            if not os.path.exists(resultdir):
                os.makedirs(resultdir)
                os.chmod(resultdir, 0o777)
            res = run(f'docker create --tmpfs /tmp '
                      f'-v {os.getcwd()}/resources:/home/postgres/resources '
                      f'-v {os.getcwd()}/scripts:/home/postgres/scripts '
                      f'-v {resultdir}:/home/postgres/results '
                      f'--tty --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN '
                      f'--shm-size=2g {envvars} {instance_id}',
                      shell=True, check=True, stdout=subprocess.PIPE)
            container_id = res.stdout.decode('utf-8').strip()
            bminstance = SubElement(bmbench, 'instance')
            bminstance.set('started', datetime.datetime.now().
                           replace(microsecond=0).isoformat())
            bminstance.set('id', instance_uid)
            try:
                if pg_params:
                    # pylint: disable=consider-using-with
                    tcfile = tempfile.NamedTemporaryFile(mode='w+t',
                                                         delete=False)
                    tcfile.write(pg_params)
                    tcfile.close()
                    os.chmod(tcfile.name, 0o755)
                    run(f'docker cp "{tcfile.name}" '
                        f'{container_id}:/home/postgres/extra.conf',
                        shell=True, check=True, stdout=subprocess.PIPE)
                    os.unlink(tcfile.name)

                run(f'docker start {container_id} >/dev/null',
                    shell=True, check=True)
                sleep(5)  # wait for database startup
                if verbose:
                    print('\tRunning common prepare...')
                res = run(
                    f'docker exec -t {container_id} bash -c '
                    f'"scripts/common/prepare >results/cprepare.log 2>&1"',
                    shell=True, check=False, stdout=subprocess.PIPE)
                if res.returncode != 0:
                    print(res.stdout.decode('utf-8'))
                    raise Exception('Prepare failed! (For details '
                                    'see benchmark-results/.)')

                if prepare is not None:
                    if verbose:
                        print('\tRunning prepare...')
                    prepcmd = prepare.replace('"', '\\"')
                    res = run(f'docker exec -t {container_id} bash -c '
                              f'"{prepcmd}"',
                              shell=True, check=False, stdout=subprocess.PIPE)
                    if res.returncode != 0:
                        print(res.stdout.decode('utf-8'))
                        raise Exception('Prepare failed! (For details '
                                        'see benchmark-results/.)')

                if verbose:
                    print('\tRunning benchmark...')
                execcmd = execute.replace('"', '\\"')
                res = run(f'docker exec -t {container_id} bash -c "{execcmd}"',
                          shell=True, check=False, stdout=subprocess.PIPE)
                if verbose:
                    print('\tBenchmark finished.')
                output = res.stdout.decode('utf-8').replace('\r\n', '\n')
                if res.returncode != 0:
                    print(output)
                    raise Exception('Benchmark execution failed! (For details '
                                    'see benchmark-results/.)')

                instance_features = instance.get('features')
                if instance_features is not None and \
                   re.match(r'\bperf\b', instance_features):
                    res = run(f'docker exec -t {container_id} bash -c '
                              f'pg_ctl_stop',
                              shell=True, check=False, stdout=subprocess.PIPE)
                    if res.returncode != 0:
                        print(res.stdout.decode('utf-8'))
                        raise Exception('Could not stop server.')
                    sleep(10)
                    res = run(f'docker exec -t {container_id} bash -c "'
                              f'perf report --stdio -i'
                              f' /home/postgres/results/perf.data'
                              f' >/home/postgres/results/perf.out 2>&1; '
                              f'perf script -i'
                              f' /home/postgres/results/perf.data'
                              f' >/home/postgres/results/perf.script 2>&1"',
                              shell=True, check=False, stdout=subprocess.PIPE)
                    if res.returncode != 0:
                        print(res.stdout.decode('utf-8'))
                        raise Exception('Could not get perf report.')

                for metric in bench.findall('./results/metric'):
                    mid = metric.get('id')
                    mre = metric.get('regexp')
                    if mre is not None:
                        match = re.search(mre, output, re.MULTILINE)
                        if match is None:
                            print(output)
                            raise Exception(f'Metric {mid} is not found!')
                        bmmetric = SubElement(bminstance, 'metric')
                        bmmetric.set('id', mid)
                        if metric.get('type') is None or \
                           metric.get('type') == 'float':
                            mval = match.group(1)
                            val = float(mval)
                            bmmetric.set('value', str(val))
                        elif metric.get('type') == 'm_s':
                            val = float(match.group(1)) * 60 + \
                                float(match.group(2))
                            bmmetric.set('value', str(val))
                        elif metric.get('type') == 'string':
                            bmmetric.set('value', match.group(1).strip())
                for metricset in bench.findall('./results/metricset'):
                    mpid = metricset.get('id')
                    sbstn = 1
                    for sbstn in range(1, 9):
                        if ('$' + str(sbstn)) not in mpid:
                            break
                    mre = metricset.get('regexp')
                    if mre is not None:
                        matches = re.findall(mre, output, re.MULTILINE)
                        for match in matches:
                            bmmetric = SubElement(bminstance, 'metric')
                            mid = mpid
                            for sbsti in range(1, sbstn):
                                mid = mid.replace('$' + str(sbsti),
                                                  match[sbsti - 1])
                            bmmetric.set('id', mid)
                            if metricset.get('type') is None or \
                               metricset.get('type') == 'float':
                                bmmetric.set('value',
                                             str(float(match[sbstn - 1])))
                if len(list(bminstance)) == 0:
                    bmbench.remove(bminstance)
                else:
                    bminstance.set('ended', datetime.datetime.now().
                                   replace(microsecond=0).isoformat())
                    ElementTree(restop).write(resultsfile, encoding='utf-8',
                                              xml_declaration=True)

                res = run(f'docker stop {container_id} >/dev/null',
                          shell=True, check=False, stdout=subprocess.PIPE)
                if res.returncode != 0:
                    print(f'Unable to stop the container. '
                          f'Error: {res.returncode};\n' +
                          res.stdout.decode('utf-8'))
                res = run(f'docker rm {container_id} >/dev/null',
                          shell=True, check=False, stdout=subprocess.PIPE)
                if res.returncode != 0:
                    print(f'Unable to remove the container. '
                          f'Error: {res.returncode};\n' +
                          res.stdout.decode('utf-8'))
                run('for dv in $(docker volume ls -q -f dangling=true);'
                    ' do docker volume rm $dv >/dev/null; done',
                    shell=True, check=True)
            finally:
                pass

    bmrun.set('ended', datetime.datetime.now().
              replace(microsecond=0).isoformat())

    ElementTree(restop).write(resultsfile, encoding='utf-8',
                              xml_declaration=True)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('-c', '--config', action='store',
                            default='config.xml',
                            help='configuration file')
    arg_parser.add_argument('-v', '--verbose', action='store_true',
                            default=False,
                            help='verbose messages')
    arg_parser.add_argument('-i', '--instance', nargs='+',
                            dest='instances', metavar='INSTANCE-ID',
                            default=[],
                            help='target instance(s)')
    arg_parser.add_argument('-b', '--benchmark', nargs='+',
                            dest='benchmarks', metavar='BENCHMARK-ID',
                            default=[],
                            help='benchmark(s) to run')
    arg_parser.add_argument('-r', '--results', action='store',
                            dest='resultsfile', metavar='RESULTS-FILE',
                            default='benchmark-results.xml',
                            help='benchmark results file')
    arg_parser.add_argument('-rd', '--resultsdir', action='store',
                            dest='resultsdir', metavar='RESULTS-DIR',
                            default='benchmark-results',
                            help='benchmark results directory')

    cmdLine = arg_parser.parse_args(sys.argv[1:])
    verbose = cmdLine.verbose
    sys.exit(main(cmdLine.config, cmdLine.instances, cmdLine.benchmarks,
                  cmdLine.resultsfile, cmdLine.resultsdir))
