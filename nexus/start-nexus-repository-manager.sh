#!/bin/bash
#
# Copyright:: Copyright (c) 2017-present Sonatype, Inc. Apache License, Version 2.0.
#
chown -R 200:200 /nexus-data/
rm -rf /nexus-data/lock
cd /opt/sonatype/nexus
exec ./bin/nexus run
