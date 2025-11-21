#!/bin/bash
# Wrapper script to run Metasploit with proper environment

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/bundle/bin
export BUNDLE_GEMFILE=/usr/src/metasploit-framework/Gemfile
export MSF_ROOT=/usr/src/metasploit-framework

cd /usr/src/metasploit-framework

# Run msfconsole directly with bundle exec
exec /usr/local/bin/bundle exec ruby ./msfconsole "$@"
