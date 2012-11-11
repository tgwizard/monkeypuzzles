#!/usr/bin/env rackup
# encoding: utf-8
#
require 'rack/canonical_host'
use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']

# This file can be used to start Padrino,
# just execute it from the command line.
require File.expand_path("../config/boot.rb", __FILE__)

run Padrino.application
