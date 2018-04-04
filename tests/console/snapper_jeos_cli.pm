# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Snapshot creation and rollback on JeOS
# Maintainer: Michal Nowak <mnowak@suse.com>

use base 'consoletest';
use testapi;
use utils;
use strict;

sub run {
    my ($self) = @_;

    select_console('root-console');
    my $file = '/root/openQA_snapper_test';
    assert_script_run("touch $file");
    my $openqalatest = 'openqalatest';
    assert_script_run("snapper create -d $openqalatest");
    assert_script_run("snapper list");
    my $latest_snapshot = script_output("snapper list | grep -w $openqalatest | awk '{ print \$3 }' | tr -d '\\n'");
    my $init_snapshot   = script_output("snapper list | grep 'single.*Initial Status' | awk '{ print \$3 }' | tr -d '\\n'");
    my $openqarollback  = 'openqarollback';
    assert_script_run("snapper rollback -d $openqarollback $init_snapshot");
    assert_script_run("snapper list");
    power_action('reboot');
    $self->wait_boot;

    select_console('root-console');
    assert_script_run("snapper list");
    assert_script_run("! ls -l $file");
    assert_script_run("snapper rollback $latest_snapshot");
    assert_script_run("snapper list");
    power_action('reboot');
    $self->wait_boot;

    select_console('root-console');
    assert_script_run("snapper list");
    assert_script_run("ls -l $file");
    assert_script_run("rm -v $file");
}

1;
# vim: set sw=4 et: