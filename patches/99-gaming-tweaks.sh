#!/system/bin/sh
# =============================================================================
# Motorola Edge 30 (dubai / SM7325) - Gaming performance runtime tweaks
# Instalado em: /data/adb/service.d/99-gaming-tweaks.sh
# Executado pelo KernelSU / Magisk apos o boot completo.
# =============================================================================

# Aguarda o boot estabilizar
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
sleep 20

LOG="/data/local/tmp/gaming_tweaks.log"
echo "[$(date)] Applying gaming tweaks..." > "$LOG"

write() {
    if [ -f "$1" ]; then
        chmod 0666 "$1" 2>/dev/null
        echo "$2" > "$1" 2>>"$LOG"
    fi
}

# =============================================================================
# KERNEL / SCHEDULER
# =============================================================================
write /proc/sys/kernel/sched_child_runs_first 1
write /proc/sys/kernel/sched_autogroup_enabled 1
write /proc/sys/kernel/sched_tunable_scaling 0
write /proc/sys/kernel/sched_latency_ns 3000000
write /proc/sys/kernel/sched_min_granularity_ns 300000
write /proc/sys/kernel/sched_wakeup_granularity_ns 500000
write /proc/sys/kernel/sched_migration_cost_ns 500000
write /proc/sys/kernel/sched_nr_migrate 128
write /proc/sys/kernel/sched_schedstats 0
write /proc/sys/kernel/randomize_va_space 0
write /proc/sys/kernel/perf_cpu_time_max_percent 5
write /proc/sys/kernel/timer_migration 0

# Reduz overhead de printk
write /proc/sys/kernel/printk "0 0 0 0"

# =============================================================================
# CPU: manter todos os cores online e permitir boosts
# =============================================================================
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    write "$cpu/online" 1
done

# GPU boost / desligar power collapse durante games
write /sys/class/kgsl/kgsl-3d0/force_no_nap 1
write /sys/class/kgsl/kgsl-3d0/force_bus_on 1
write /sys/class/kgsl/kgsl-3d0/force_clk_on 1
write /sys/class/kgsl/kgsl-3d0/force_rail_on 1
write /sys/class/kgsl/kgsl-3d0/throttling 0
write /sys/class/kgsl/kgsl-3d0/devfreq/adrenoboost 2
write /sys/class/kgsl/kgsl-3d0/idle_timer 100

# =============================================================================
# WORKQUEUE
# =============================================================================
write /sys/module/workqueue/parameters/power_efficient N
write /sys/module/workqueue/parameters/disable_numa Y

# =============================================================================
# VM / MEMORIA
# =============================================================================
write /proc/sys/vm/swappiness 80
write /proc/sys/vm/vfs_cache_pressure 80
write /proc/sys/vm/dirty_ratio 40
write /proc/sys/vm/dirty_background_ratio 15
write /proc/sys/vm/dirty_expire_centisecs 3000
write /proc/sys/vm/dirty_writeback_centisecs 1500
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/stat_interval 30
write /proc/sys/vm/oom_kill_allocating_task 1
write /proc/sys/vm/overcommit_memory 1
write /proc/sys/vm/watermark_scale_factor 100
write /proc/sys/vm/extfrag_threshold 750

# LMK / PSI
write /proc/sys/vm/compaction_proactiveness 0

# =============================================================================
# I/O: schedulers rapidos e read-ahead adequado
# =============================================================================
for q in /sys/block/*/queue; do
    write "$q/scheduler" "none"
    write "$q/scheduler" "mq-deadline"
    write "$q/read_ahead_kb" 256
    write "$q/nr_requests" 256
    write "$q/iostats" 0
    write "$q/add_random" 0
    write "$q/nomerges" 0
    write "$q/rq_affinity" 2
done

# UFS especifico
for ufs in /sys/block/sd*/queue /sys/block/mmcblk*/queue; do
    write "$ufs/read_ahead_kb" 512
done

# =============================================================================
# NETWORK: BBR + low latency + fast open
# =============================================================================
write /proc/sys/net/ipv4/tcp_congestion_control bbr
write /proc/sys/net/core/default_qdisc fq
write /proc/sys/net/ipv4/tcp_low_latency 1
write /proc/sys/net/ipv4/tcp_fastopen 3
write /proc/sys/net/ipv4/tcp_slow_start_after_idle 0
write /proc/sys/net/ipv4/tcp_sack 1
write /proc/sys/net/ipv4/tcp_timestamps 0
write /proc/sys/net/ipv4/tcp_ecn 1
write /proc/sys/net/ipv4/tcp_tw_reuse 1
write /proc/sys/net/ipv4/tcp_no_metrics_save 1
write /proc/sys/net/ipv4/tcp_moderate_rcvbuf 1
write /proc/sys/net/ipv4/tcp_syn_retries 3
write /proc/sys/net/ipv4/tcp_synack_retries 3
write /proc/sys/net/ipv4/tcp_keepalive_time 60
write /proc/sys/net/ipv4/tcp_keepalive_intvl 15
write /proc/sys/net/ipv4/tcp_keepalive_probes 3
write /proc/sys/net/core/somaxconn 4096
write /proc/sys/net/core/netdev_max_backlog 16384
write /proc/sys/net/core/rmem_max 16777216
write /proc/sys/net/core/wmem_max 16777216
write /proc/sys/net/core/rmem_default 262144
write /proc/sys/net/core/wmem_default 262144
write /proc/sys/net/core/optmem_max 65536
write /proc/sys/net/core/busy_poll 50
write /proc/sys/net/core/busy_read 50

# =============================================================================
# FILESYSTEM / RANDOMNESS
# =============================================================================
write /proc/sys/fs/lease-break-time 10
write /proc/sys/fs/leases-enable 1
write /proc/sys/kernel/random/read_wakeup_threshold 128
write /proc/sys/kernel/random/write_wakeup_threshold 1024

# =============================================================================
# ENTROPY / IRQ affinity: espalhar IRQs entre cores
# =============================================================================
for irq in /proc/irq/*/smp_affinity_list; do
    write "$irq" "0-7" 2>/dev/null
done

# =============================================================================
# LOW POWER MODE OFF durante uso ativo (deixa o sistema decidir depois)
# =============================================================================
write /sys/module/lpm_levels/parameters/sleep_disabled N

# =============================================================================
# DROP CACHES uma vez para comecar limpo
# =============================================================================
sync
write /proc/sys/vm/drop_caches 3

echo "[$(date)] Gaming tweaks applied successfully." >> "$LOG"
exit 0
