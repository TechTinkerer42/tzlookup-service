#!/usr/bin/env puma

quiet
threads 8,32
bind 'tcp://0.0.0.0:8080'

directory '{{ deployment_path }}'
pidfile '{{ deployment_path }}/tmp/puma/pid'
state_path '{{ deployment_path }}/tmp/puma/state'

