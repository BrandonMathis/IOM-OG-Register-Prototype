#!/bin/sh
rake db:clear; ./script/runner db/sample/topology.rb; ./script/runner 'puts TopologyAsset.find_by_guid("317d6bc3-2e6d-4d80-addb-2f3fcff9e5ff").entry_edge.source.to_xml'
