#!/vendor/bin/sh
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Spread the busiest device interrupts over the little cores.
#
# Stock balances interrupts with msm_irqbalance, which isn't shipped here, so
# every device interrupt (and the softirq work it raises) lands on CPU0, which
# also runs app threads. Pin each busy source to its own little core instead,
# keeping the A78s (cpu6-7) free of interrupts and CPU0 for timers and the rest.
# Interrupts are matched by handler name because their numbers can change
# between boots; a source that isn't present is simply skipped.

pin() {
    cpus=$1
    shift
    for irq in /proc/irq/[0-9]*; do
        for name in "$@"; do
            for handler in "$irq"/$name; do
                if [ -d "$handler" ]; then
                    echo "$cpus" > "$irq/smp_affinity_list"
                fi
            done
        done
    done
}

pin 1 msm_drm chipone-tddi ilitek    # display and touch
pin 2 kgsl_3d0_irq                   # GPU
pin 3 ufshcd                         # storage
pin 4 'WLAN_CE_*'                    # Wi-Fi copy engines
pin 5 ipa                            # IP accelerator (mobile data)
