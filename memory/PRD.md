# PRD — GitHub Actions: Build Kernel Motorola Edge 30 (dubai) + KernelSU-Next

## Problema original
Implementar workflow (`.yml`) do GitHub Actions para compilar o kernel Android 5.4 do Motorola Edge 30 (codinome `dubai`, SoC SM7325 / Lahaina) a partir do repositório `matehuspegador/android_kernel_motorola_sm7325`, branch `lineage-20`, e integrar KernelSU ao kernel.

## Escolhas do usuário
- Local: `/app/.github/workflows/build-kernel.yml`
- Toolchain: **Proton Clang** (kdrag0n)
- Empacotamento: **AnyKernel3** (zip flashável)
- Root: **KernelSU-Next** (via `setup.sh` oficial)
- Defconfig: `lahaina-qgki_defconfig`

## Arquitetura
- Runner: `ubuntu-22.04` do GitHub
- Cache: `ccache` (5 GB) via `hendrikmuhs/ccache-action`
- Clones: kernel (depth=1), proton-clang, AnyKernel3
- Integração KernelSU-Next: `curl setup.sh | bash -s <branch>` + `CONFIG_KSU=y` + kprobes no defconfig
- Build: `make O=out CC="ccache clang" LD=ld.lld ...`
- Empacotamento: copia `Image.gz-dtb` / `Image.gz` / `Image` + `dtbo.img` + `dtb.img` para AnyKernel3 e gera zip
- Artefatos: zip AnyKernel3, imagem raw, log de build (em falha)
- Release automático opcional via `softprops/action-gh-release@v2`

## Entregas
- `.github/workflows/build-kernel.yml` (workflow completo, 15 steps, validado como YAML)
- `.github/workflows/README.md` (instruções de uso, flash, troubleshooting)

## Inputs do workflow (workflow_dispatch)
- `kernelsu_next`: true/false — integrar KernelSU-Next
- `kernelsu_branch`: branch/tag do KernelSU-Next (`next`, `next-susfs`, tags)
- `release`: true/false — criar Release automático

## Status
- Workflow criado e validado sintaticamente (YAML OK)
- Não é possível executar o build de kernel dentro deste ambiente (é feito no runner do GitHub Actions após push para o repo do usuário)

## Próximos passos (usuário)
1. Copiar `.github/workflows/build-kernel.yml` para o seu repositório no GitHub
2. Actions → Run workflow
3. Baixar o zip AnyKernel3 gerado e flashar via TWRP/OrangeFox

## Backlog / melhorias futuras
- Suporte a matrix build (com/sem KSU em paralelo)
- Integração SUSFS automática
- Assinatura do zip
- Notificação via Telegram ao finalizar build
