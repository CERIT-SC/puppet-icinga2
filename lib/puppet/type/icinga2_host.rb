$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))
require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'icinga2_host',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage host in icinga2.
    EOS
  features: ['simple_get_filter'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this node should be present or absent on the system. Default value is present.',
      default: 'present',
    },
    name: {
      type: 'String',
      desc: 'Name of host. Value must be string type.',
      behaviour: :namevar,
    },
    address: {
      type: 'String',
      desc: 'IPv4 of host',
    },
    display_name: {
      type: 'Optinal[String]',
      desc: 'A name for displaying',
      #default: TODO
    },
    groups: {
      type: 'Array',
      desc: 'Groups of node',
      default: [],
    },
    templates: {
      type: 'Array',
      desc: 'templates',
      default: [],
    },
    vars: {
      type: 'Hash',
      desc: 'variables',
      default: {},
    },
    check_command: {
      type: 'String',
      desc: 'check command',
      default: "hostalive",
    },
    check_interval: {
      type: 'Integer',
      desc: 'check interval',
      default: 300,
    },
    retry_interval: {
      type: 'Integer',
      desc: 'retry interval',
      default: 60,
    },
    check_timeout: {
      type: 'Integer',
      desc: 'check timeout',
      default: 30,
    },
    enable_active_checks: {
      type: 'Boolean',
      desc: 'enable active checks',
      default: true,
    },
    enable_event_handler: {
      type: 'Boolean',
      desc: 'enable event handler',
      default: true,
    },
    enable_notifications: {
      type: 'Boolean',
      desc: 'enable notifications',
      default: false,
    },
    url: {
      type: 'String',
      desc: 'icinga url',
      behaviour: 'parameter', 
    },
  },
)
