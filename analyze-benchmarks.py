#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" This script helps to analyze the benchmark-results.xml file.
"""

# pylint: disable=invalid-name

import sys
import xml.etree.ElementTree
import argparse
import re

verbose = False


def main(instances, resultsfile, percent, targetmetric, targetvalue):
    """
    Main function to compare serveral instances results or
    compare a single instance results with a target metric
    """
    # pylint: disable=too-many-branches,too-many-locals,too-many-nested-blocks
    # pylint: disable=too-many-statements

    result = 0
    selected_bench = None
    selected_metric = None
    if targetmetric is not None:
        tmparts = targetmetric.split('.', 1)
        if len(tmparts) != 2:
            print('Target metric should be specified in form "test.metric".')
            return 1
        selected_bench = tmparts[0]
        selected_metric = tmparts[1]
        if targetvalue is not None:
            targetvalue = float(targetvalue)
    else:
        targetvalue = None

    if not (len(instances) == 2 or
            (len(instances) == 1 and
             selected_bench is not None and targetvalue is not None)):
        print("You need to specify two instances (patterns) or"
              " one instance and the valid target metric/value.")
        return 1

    restop = xml.etree.ElementTree.parse(resultsfile).getroot()
    bmrun = restop.find('run')
    maininst = instances[0]
    for bench in bmrun.findall('benchmark'):
        bench_id = bench.get('id')
        if bench_id == 'version':
            continue
        if selected_bench is not None and selected_bench != bench_id:
            continue
        metrics = {}
        for inst in bench.findall('instance'):
            inst_id = inst.get('id')
            inst_ipat = None
            for ipat in instances:
                if re.match(ipat, inst_id):
                    if inst_ipat:
                        print(
                         f"Instance \"{inst_id}\" matches two patterns: "
                         f"\"{inst_ipat}\" and \"{ipat}\".")
                        return 1
                    inst_ipat = ipat
                    for metric in inst.findall('metric'):
                        metric_id = metric.get('id')
                        if selected_metric is not None and \
                           metric_id != selected_metric:
                            continue
                        if metric_id not in metrics:
                            metrics[metric_id] = {}
                        if ipat not in metrics[metric_id]:
                            metrics[metric_id][ipat] = []
                        value = float(metric.get('value'))
                        if metric_id.startswith(('tps', 'tpm', 'xacts')) or \
                           metric_id.endswith(('_ops', '_rps')):
                            value = -value
                        metrics[metric_id][ipat].append(value)
            if not inst_ipat:
                print(
                 f"Instance \"{inst_id}\" skipped as not matching "
                 f"to any of the patterns.")

        for metric, ipatterns in metrics.items():
            best = {}
            averages = {}
            invalid_metric_value = False
            for ipat in ipatterns:
                msum = 0
                mmin = 0
                cnt = 0
                for val in ipatterns[ipat]:
                    if cnt == 0 or val < mmin:
                        mmin = val
                    msum += val
                    cnt += 1
                    if abs(val) <= 0.01:
                        invalid_metric_value = True
                        break
                if invalid_metric_value:
                    break
                best[ipat] = mmin
                averages[ipat] = msum / cnt
            if invalid_metric_value:
                continue

            bestmain = best[maininst]
            avgmain = averages[maininst]
            for ipat, curbest in best.items():
                if ipat == maininst:
                    continue
                bestpercentdiff = 100 * ((bestmain - curbest) / curbest)
                if abs(bestpercentdiff) >= percent:
                    if (bestpercentdiff < 0 < bestmain) or \
                       (bestmain < 0 < bestpercentdiff):
                        spec = 'better'
                    else:
                        spec = 'worse'
                    sign = '<' if abs(bestmain) < abs(curbest) else '>'
                    print(
                     f"Best {maininst} {spec} than {ipat} by "
                     f"{abs(bestpercentdiff):.1f} percents "
                     f"({abs(bestmain):.2f} {sign} {abs(curbest):.2f}): "
                     f"{bench_id}.{metric}")
                avgpercentdiff = 100 * ((avgmain - averages[ipat]) /
                                        averages[ipat])
                if abs(avgpercentdiff) >= percent:
                    if (avgpercentdiff < 0 < avgmain) or \
                       (avgmain < 0 < avgpercentdiff):
                        spec = 'better'
                    else:
                        spec = 'worse'
                    sign = '<' if abs(avgmain) < abs(averages[ipat]) else '>'
                    print(
                     f"Average {maininst} {spec} than {ipat} by "
                     f"{abs(avgpercentdiff):.1f} percents "
                     f"({abs(avgmain):.2f} {sign} {abs(averages[ipat]):.2f}): "
                     f"{bench_id}.{metric}")
            if targetvalue is not None:
                if (0 < avgmain <= targetvalue) or \
                   (avgmain < - float(targetvalue) < 0):
                    res = 'good'
                else:
                    res = 'bad'
                    result = 2
                print(f"Results considered {res} "
                      f"({targetmetric}: {abs(avgmain)} vs {targetvalue}).")
    return result


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument(
        '-i', '--instance', nargs='+',
        dest='instances', metavar='INSTANCE-ID',
        default=[],
        help='patterns specifying instances to compare')
    arg_parser.add_argument(
        '-r', '--results', action='store',
        dest='resultsfile', metavar='RESULTS-FILE',
        default='benchmark-results.xml',
        help='benchmark results file')
    arg_parser.add_argument(
        '-p', '--percent', action='store',
        dest='percent', default='5',
        help='percent to consider change significant')
    arg_parser.add_argument(
        '-m', '--metric', action='store',
        dest='metric',
        help='target metric to restrict analyze')
    arg_parser.add_argument(
        '-t', '--target', action='store',
        dest='targetvalue',
        help='target average value for the metric to consider results good')
    arg_parser.add_argument(
        '-v', '--verbose', action='store_true',
        default=False,
        help='verbose messages')
    cmdLine = arg_parser.parse_args(sys.argv[1:])
    verbose = cmdLine.verbose
    sys.exit(main(cmdLine.instances, cmdLine.resultsfile,
                  float(cmdLine.percent), cmdLine.metric, cmdLine.targetvalue))
