$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))
require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'service',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage service in icinga2.
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
    check_commmand: {
      type: 'String',
      desc: 'check command',
    },
    templates: {
      type: 'Optional[Array]',
      desc: 'templates',
      default: [],
    },
    vars: {
      type: 'Optional[Hash]',
      desc: 'variables',
      default: {},
    },
    check_interval: {
      type: 'Optional[Integer]',
      desc: 'check interval',
      default: 300,
    },
    retry_interval: {
      type: 'Optional[Integer]',
      desc: 'retry interval',
      default: 60,
    },
    check_timeout: {
      type: 'Optional[Integer]',
      desc: 'check timeout',
      default: 30,
    },
    enable_notifications: {
      type: 'Optional[Boolean]',
      desc: 'enable notifications',
      default: false,
    },
    notification_user_groups: {
      type: 'Optional[Array]',
      desc: 'groups for notifications',
      default: [],
    },
    notification_users: {
      type: 'Optional[Array]',
      desc: 'users for notifications',
      default: [],
    },
    notification_templates: {
      type: 'Optional[Array]',
      desc: 'templates for notification',
      default: [],
    },
  },
)
