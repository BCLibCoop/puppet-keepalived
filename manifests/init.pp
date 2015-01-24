# Keepalived templating module by James
# Copyright (C) 2012-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class keepalived (
        $groups = ['default'],                  # auto make these empty groups
        $shorewall = true,                      # generate shorewall vrrp rules
        $conntrackd = false,                    # enable conntrackd integration
        $start = false                          # start on boot and keep running
) {
        package { 'keepalived':
                ensure => present,
        }

        $ensure = $start ? {
                true => running,
                default => undef,               # we don't want ensure => stopped
        }

        service { 'keepalived':
                enable => $start,               # start on boot
                ensure => $ensure,              # ensures nothing if undef
                hasstatus => true,              # use status command to monitor
                hasrestart => true,             # use restart, not start; stop
                require => Package['keepalived'],
        }

        file { '/etc/keepalived/':
                ensure => directory,            # make sure this is a directory
                recurse => true,                # recursively manage directory
                purge => true,                  # purge all unmanaged files
                force => true,                  # also purge subdirs and links
                owner => root,
                group => root,
                mode => '0644',                 # u=rwx,go=rx
                notify => Service['keepalived'],
                require => Package['keepalived'],
        }

        file { '/etc/keepalived/groups/':
                ensure => directory,            # make sure this is a directory
                recurse => true,                # recursively manage directory
                purge => true,                  # purge all unmanaged files
                force => true,                  # also purge subdirs and links
                owner => root,
                group => root,
                mode => '0644',                 # u=rwx,go=rx
                #notify => Service['keepalived'],
                require => File['/etc/keepalived/'],
        }

        file { '/etc/keepalived/keepalived.conf':
                content => template('keepalived/keepalived.conf.erb'),
                owner => root,
                group => root,
                mode => '0600',         # u=rw
                ensure => present,
                notify => Service['keepalived'],
        }

        # automatically create some empty groups for autogrouping
        keepalived::group { $groups:
                autogroup => true,
        }
}

# vim: ts=8
# vim: set ft=puppet si sts=2 et tw=80 sw=2:
