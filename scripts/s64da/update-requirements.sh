#!/bin/bash

# Update versions of pip modules for modern OS
# (namely, Ubuntu 22.04 requires newer pandas and psycopg2-binary)
sed "s/pandas==1.0.2/pandas==1.3.5/; s/Jinja2==2.11.1/Jinja2==3.1.2/; s/numpy==1.18.1/numpy==1.24.3/; s/python-dateutil==2.8.0/python-dateutil==2.8.2/; s/pytz==2019.1/pytz==2023.3/; s/MarkupSafe==1.1.1/MarkupSafe/; s/psycopg2-binary==2.8.5/psycopg2-binary==2.9.6/; s/tabulate==0.8.6/tabulate==0.9.0/;" -i s64da-benchmark/requirements.txt
