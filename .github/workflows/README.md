# Build Kernel — Motorola Edge 30 (dubai) + KernelSU-Next

Workflow do **GitHub Actions** para compilar o kernel Android 5.4 do **Motorola Edge 30 (codinome `dubai`, SoC SM7325 / Lahaina)** com base no fork **LineageOS 20** de `matehuspegador/android_kernel_motorola_sm7325`, empacotado como **AnyKernel3** (zip flashável em recovery) e com **KernelSU-Next** integrado automaticamente.

Arquivo: `.github/workflows/build-kernel.yml`

---

## Recursos

- Ubuntu 22.04 runner (grátis do GitHub)
- Toolchain: **Proton Clang** (kdrag0n)
- Defconfig: `lahaina-qgki_defconfig`
- Cache com `ccache` (até 5 GB) → builds subsequentes ~5x mais rápidas
- KernelSU-Next integrado via script oficial (`setup.sh`), com branch/tag configurável
- Empacotamento **AnyKernel3** flashável no TWRP/OrangeFox
- Upload de artefatos (zip + Image raw + dtb/dtbo)
- Release automático (opcional) do GitHub com o zip
- Upload do log de build em caso de falha

---

## Como usar

1. **Faça fork** ou copie o repositório onde este workflow deve rodar.
   Você **não precisa** hospedar o código do kernel — o workflow clona o repositório do kernel automaticamente.

2. Coloque o arquivo `.github/workflows/build-kernel.yml` no seu repositório.

3. Vá em **Actions → Build Kernel - Motorola Edge 30 (dubai) + KernelSU-Next → Run workflow**.

4. Preencha os inputs (opcional):
   - `kernelsu_next`: `true` para integrar KernelSU-Next (padrão), `false` para kernel stock.
   - `kernelsu_branch`: branch/tag do KernelSU-Next (`next` = default; use `next-susfs` para SUSFS, ou uma tag como `v1.0.5`).
   - `release`: `true` gera Release automático no seu repo.

5. Ao final, baixe o `.zip` em **Artifacts** ou na aba **Releases**.

---

## Flashar

1. Reinicie no **Recovery** (TWRP / OrangeFox) do Edge 30.
2. `Install` → selecione o zip `Kernel-dubai-lineage20-KSUNext-<data>.zip`.
3. Reboot.
4. Instale o app **KernelSU Next Manager** para gerenciar root.

> ⚠️ **Faça backup** do boot atual antes de flashar.

---

## Personalização rápida

Edite as variáveis no topo do `build-kernel.yml`:

```yaml
env:
  KERNEL_REPO: "https://github.com/matehuspegador/android_kernel_motorola_sm7325"
  KERNEL_BRANCH: "lineage-20"
  KERNEL_DEFCONFIG: "lahaina-qgki_defconfig"
  DEVICE_CODENAME: "dubai"
```

- Trocar toolchain: substitua o step **Clone Proton Clang** por AOSP Clang.
- Adicionar patches: crie um step antes de **Build kernel** aplicando `git apply` ou `patch -p1`.

---

## Solução de problemas

| Problema | Causa provável | Fix |
|---|---|---|
| `defconfig não encontrado` | nome errado do defconfig | verifique `arch/arm64/configs/` no repositório |
| Erro `implicit declaration` | incompatibilidade Clang | tente Clang do AOSP r450784d |
| `Image.gz-dtb` não gerado | dtb não concatenado | apenas `Image.gz` é gerado — AnyKernel3 aceita, ajuste `anykernel.sh` |
| Build muito lento | primeira execução (ccache vazio) | próximos builds serão bem mais rápidos |

---

## Créditos

- Kernel source: [matehuspegador/android_kernel_motorola_sm7325](https://github.com/matehuspegador/android_kernel_motorola_sm7325)
- Toolchain: [kdrag0n/proton-clang](https://github.com/kdrag0n/proton-clang)
- Packaging: [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- Root: [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)
