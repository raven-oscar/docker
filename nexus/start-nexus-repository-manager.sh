#!/bin/bash
#
# Copyright:: Copyright (c) 2017-present Sonatype, Inc. Apache License, Version 2.0.
#
chown -R nexus:nexus /nexus-data/
rm -rf /nexus-data/lock
cd /opt/sonatype/nexus
su - nexus -c "exec ./bin/nexus run"
