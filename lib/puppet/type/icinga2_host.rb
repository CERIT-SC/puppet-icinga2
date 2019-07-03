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
      type: 'Optional[String]',
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
      type: 'Float',
      desc: 'check interval',
      default: 300.0,
    },
    retry_interval: {
      type: 'Float',
      desc: 'retry interval',
      default: 60.0,
    },
    check_timeout: {
      type: 'Float',
      desc: 'check timeout',
      default: 30.0,
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
  },
)
