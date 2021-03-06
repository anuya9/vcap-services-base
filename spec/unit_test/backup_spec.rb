# Copyright (c) 2009-2011 VMware, Inc.
require 'helper/spec_helper'
require 'eventmachine'

describe BackupTest do
  it "should exit after receive TERM signal" do
    EM.run do
      pid = Process.pid
      backup = BackupTest::ZombieBackup.new
      EM.defer do
        backup.start
      end
      EM.add_timer(1) { Process.kill("TERM", pid) }
      EM.add_timer(5) do
        expect(backup.exit_invoked).to eq(true)
        EM.stop
      end
    end
  end

  it "should return true if execution suceeds" do
    errback_called = false
    on_err = Proc.new do |cmd, code, msg|
      errback_called = true
    end
    res = CMDHandle.execute("echo", 1, on_err)
    expect(res).to eq(true)
    expect(errback_called).to eq(false)
  end

  it "should handle errors if the executable is not found or execution fails" do
    ["cmdnotfound", "ls filenotfound"].each do |cmd|
      errback_called = false
      on_err = Proc.new do |cmd, code, msg|
        errback_called = true
      end
      res = CMDHandle.execute(cmd, 1, on_err)
      expect(res).to eq(false)
      expect(errback_called).to eq(true)
    end
  end
end
