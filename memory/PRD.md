# PRD — GitHub Actions: Build Kernel Motorola Edge 30 (dubai) + KernelSU-Next + Gaming Patches

## Problema
Compilar kernel Android 5.4 do Motorola Edge 30 (dubai, SM7325) via GitHub Actions com KernelSU-Next e otimizações de desempenho para jogos, gerando UM zip AnyKernel3 flashável via ADB sideload.

## Escolhas do usuário
- Local: `/app/.github/workflows/build-kernel.yml`
- Kernel source: `matehuspegador/android_kernel_motorola_sm7325` branch `lineage-20`
- Defconfig: `lahaina-qgki_defconfig`
- Toolchain: Proton Clang (kdrag0n)
- Root: KernelSU-Next (branch `next`)
- Packaging: AnyKernel3 (osm0sis)
- Gaming patches: SIM (compile-time + runtime)

## Estrutura de arquivos entregue
```
/app/
├── .github/workflows/
│   ├── build-kernel.yml    # workflow completo (17 steps)
│   └── README.md            # instruções de uso
├── patches/
│   ├── gaming.config        # fragmento de defconfig (compile-time)
│   └── 99-gaming-tweaks.sh  # script runtime instalado em /data/adb/service.d/
└── memory/PRD.md
```

## Gaming patches — camada 1 (compile-time, `gaming.config`)
- BBR + FQ + FQ_CODEL (rede)
- HZ=300, HIGH_RES_TIMERS, PREEMPT (latência)
- ZRAM LZ4 (memória)
- Kyber + BFQ (I/O)
- schedutil default (CPU)

## Gaming patches — camada 2 (runtime, `99-gaming-tweaks.sh`)
- Scheduler tunables (latency, granularity, migration)
- CPU: mantém todos os cores online, tira power collapse
- GPU (KGSL): força clocks on, adrenoboost, sem nap
- VM: swappiness, dirty ratio, watermark_scale, drop_caches inicial
- I/O: scheduler none/mq-deadline, read-ahead 512kb UFS
- Rede: BBR, TCP low latency, fastopen, buffers 16MB, busy_poll
- Workqueue: power_efficient=N
- IRQ affinity: espalha entre CPUs 0-7

## Workflow (17 steps)
1. Checkout
2. Set up build environment
3. Set up ccache (5GB)
4. Prepare workspace
5. Clone kernel source
6. **Apply gaming defconfig fragment**
7. Clone Proton Clang
8. Clone AnyKernel3
9. **Bundle gaming runtime tweaks into AnyKernel3**
10. Integrate KernelSU-Next
11. Build kernel
12. Verify kernel image
13. Package with AnyKernel3
14. Upload kernel zip
15. Upload raw kernel image
16. Upload build log on failure
17. Create GitHub Release

## Status
- YAML validado ✅
- Shell syntax do script runtime validado ✅
- Sed do heredoc testado localmente ✅
- Build real só é possível no runner do GitHub Actions após push

## Próximos passos (usuário)
1. Copiar `.github/workflows/build-kernel.yml`, `patches/gaming.config` e `patches/99-gaming-tweaks.sh` para o repositório GitHub
2. Actions → Run workflow
3. Baixar `Kernel-dubai-lineage20-KSUNext-Gaming-<data>.zip` da Release
4. `adb sideload <zip>` no recovery

## Backlog / melhorias futuras
- SUSFS patches
- Matrix build (com/sem KSU em paralelo)
- Notificação Telegram
- Módulo KSU separado para tweaks ajustáveis por perfil (jogo/normal/bateria)
