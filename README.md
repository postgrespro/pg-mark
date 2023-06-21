Postgres Benchmarking Infrastructure
=====================================


This repository contains scripts and a sample configuration file for
benchmarking different PostgreSQL and Postgres Pro versions and flavors.

#### Notice ####
Using a dedicated machine is highly recommended at least for minimizing
background/parallel activity.
Also it's recommended to disable turbo/boost CPU modes to avoid uncontrollable
and unpredictable CPU performance fluctuations.

Sample usage
-------------------------------------

0) Prepare local git repository:

    git clone git://git.postgresql.org/git/postgresql.git postgres.git
And install prerequisites:
docker, bash, wget, git, tar, 7z, ant, default-jdk  
(optional packages for visualization: xsltproc, r-base-core, r-cran-xml,
r-cran-ggplot2, r-cran-reshape2)

***

1) Run

    ./prepare-instances.py
to get all the Postgres* instances defined in config.xml ready for
benchmarking.

You can also specify different configuration file or create only selected
instances, e.g.:

    ./prepare-instances.py -i pg-src-15 pg-src-master
Run

    ./prepare-instances.py --help
to get more information.

***

2) Run

    ./run-benchmarks.py
to perform all the benchmarks Postgres* defined in config.xml for all
instances.

You'll get benchmark-results.xml with the normalized benchmarking data and
benchmark-results/ directory with a raw benchmarks' output.

You can specify a different configuration file or perform only selected
benchmarks for selected instances, e.g.:

    ./run-benchmarks.py -i pg-src-15 pg-src-master pg-src-15 pg-src-master \
      pg-src-15 pg-src-master -b pgbench_native pgbench_reference ycsb s64da_tpch

Here the instances repeated to get more trustworthy results for comparison of
that instances. The benchmark results will be stored as if the instances were
named "pg-src-15--1", "pg-src-master--1", "pg-src-15--2",
"pg-src-master--2", ...

Run

    ./run-benchmarks.py --help
to get more information.

***

3) To visualize results, you can use:

    R --no-save < VisualizeResults.R
(You'll get Rplots.pdf with graphics presenting some benchmarks results.)
Or

    xsltproc make-html-tables.xsl benchmark-results.xml >benchmark-results.html
(You'll get benchmark-results.html with tables presenting the benchmarking data.)

***

4) You can also compare benchmark results for several instances in an
automated non-visual way. Run

    ./analyze-benchmarks.py -i 'intance-1-pattern' 'intance-2-pattern'

For example, to compare results of benchmarking instances shown above, run:

    ./analyze-benchmarks.py -i 'pg-src-master--.*' 'pg-src-15--.*'

This script can also be used to perform `git bisect` for finding a commit,
that changed some metric. E. g.:

    sed "s|\(</pg_instances>\)|<instance id='pg-src-probe' type='src' git_commit='$hash' />\1|g" \
      config.xml > config-probe.xml
    time ./prepare-instances.py -c config-probe.xml -i pg-src-probe >prepare.log || exit 125
    rm benchmark-results.xml || true
    time ./run-benchmarks.py -c config-probe.xml -i pg-src-probe pg-src-probe pg-src-probe \
      pg-src-probe pg-src-probe -b s64da_tpcds
    ./analyze-benchmarks.py -i 'pg-src-probe--.*' -m s64da_tpcds.query87 -t 2.1 || exit 1

***

Configuration and data structure
-------------------------------------

A configuration of postgres instances and benchmarks is defined in a single
file config.xml (custom configuration files can also be used). It allows to
store the complete configuration of a benchmarking session along with the
results (benchmark-results.xml).

The structure of config.xml yet to be documented, but it's supposed to be
transparent and self-explanatory.


#### Notice ####
You can add private repositories and instance definitions with the following
extra configuration files:  
private_repositories.xml:

    <repository id="pgproee"
     url="https://user:password@repoee.postgrespro.ru/pgproee-$PG_VERSION/ubuntu $OS_CODENAME main" />

private_instances.xml:

    <private>
        <instance id="pg-proee-apt-15" type="proapt" pgpro_edition="ent"
         repository="pgproee" pg_version="15" />
    </private>
