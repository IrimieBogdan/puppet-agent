require 'json'

class FactDif
  EXCLUDE_LIST = %w[os.selinux.enabled disks.sr0.size_bytes disks.sda.size_bytes disks.sr1.size_bytes
      networking.interfaces.lo.mtu networking.interfaces.ens192.mtu networking.mtu fips_enabled mtu_lo
      mtu_ens192 selinux is_virtual load_averages.1m load_averages.5m load_averages.15m mountpoints./dev.available_bytes
      system_uptime.seconds system_uptime.days system_uptime.hours uptime_seconds uptime_days uptime_hours
      identity.privileged identity.gid identity.uid processors.physicalcount processors.count physicalprocessorcount
      processorcount memory.system.used memory.system.total_bytes memory.system.capacity memory.system.available_bytes
      memory.system.used_bytes memory.swap.total_bytes memory.swap.available_bytes memory.swap.used_bytes memorysize_mb
      memoryfree_mb swapsize_mb swapfree_mb partitions./dev/mapper/vglocalhost-swap_1.size_bytes
      partitions./dev/mapper/vglocalhost-root.size_bytes partitions./dev/sda1.size_bytes clientnoop
      memory.system.available memoryfree system_uptime.uptime uptime facterversion lsbmajdistrelease blockdevices
      filesystems hypervisors.vmware.version memory.swap.capacity sshfp_ecdsa sshfp_rsa sshfp_ed25519
      blockdevice_.*_vendor blockdevice_.*_model blockdevice_.*_size mountpoints.* partitions.* operatingsystemrelease
      os.release.full]


  def initialize(old_output, new_output)
    @c_facter = JSON.parse(old_output)['values']
    @next_facter = JSON.parse(new_output)['values']
    @diff = {}
  end

  def difs
    search_hash(@c_facter, [])

    @diff
  end

  private

  def search_hash(sh, path = [])
    if sh.is_a?(Hash)
      sh.each do |k, v|
        search_hash(v, path.push(k))
        path.pop
      end
    elsif sh.is_a?(Array)
      sh.each_with_index do |v, index|
        search_hash(v, path.push(index))
        path.pop
      end
    else
      compare(path, sh.to_s)
    end
  end

  def compare(fact_path, old_value)
    new_value = @next_facter.dig(*fact_path)
    if old_value != new_value && regex_exclude(fact_path.join('.'))
      @diff[fact_path.join('.')] = { new_value: new_value.inspect, old_value: old_value.inspect }
    end
  end

  def regex_exclude(fact_name)
    EXCLUDE_LIST.each do |legacy_fact|
      return false if  fact_name =~ /#{legacy_fact}/
    end

    true
  end
end

