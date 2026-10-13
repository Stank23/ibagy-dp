# Revisão e limpeza do repositório

Inventário inicial: **323 arquivos lidos** (320 texto e 3 binários), total de 7.817.342 bytes. A revisão combinou leitura de conteúdo, grafo de imports, referências em scripts/configurações, comparação de duplicatas e testes.

Removidos: **65 arquivos**, 3,590,475 bytes (~3.42 MiB), mais 13 dependências diretas. Nenhuma fórmula de folha, tabela de banco, migration, seed, licença ou registro mensal foi excluído.

## Critérios

- Componentes: subgrafo não alcançável por app, build, scripts, tools, db e configurações; referência funcional ausente.
- Pacote: arquivo tgz da raiz idêntico ao vendor mantido, com SHA-256 8dc73fc3b00203e72d176e85b50938627c7b086e607c682e8d3c22c02bb99fe8.
- Exemplos e assets: sem import/URL no código operacional.
- Inventários antigos: pertenciam ao ZIP, não validavam o repositório atual.
- Batch antigo: inicializava/enviava main; incompatível com o processo autorizado.

## Arquivos removidos

| Caminho | Razão |
|---|---|
| `components/ui/accordion.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/alert-dialog.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/alert.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/aspect-ratio.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/attachment.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/avatar.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/badge.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/breadcrumb.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/bubble.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/button-group.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/calendar.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/card.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/carousel.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/chart.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/collapsible.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/combobox.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/command.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/context-menu.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/direction.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/drawer.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/dropdown-menu.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/empty.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/field.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/form.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/hover-card.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/input-group.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/input-otp.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/item.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/kbd.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/label.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/marker.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/menubar.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/message-scroller.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/message.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/native-select.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/navigation-menu.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/pagination.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/popover.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/progress.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/radio-group.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/resizable.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/scroll-area.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/slider.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/sonner.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/spinner.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/switch.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/toggle-group.tsx` | Componente não alcançável e sem consumidor funcional |
| `components/ui/toggle.tsx` | Componente não alcançável e sem consumidor funcional |
| `bower.json` | Material/artefato SheetJS redundante; pacote vendor preservado |
| `xlsx.js` | Material/artefato SheetJS redundante; pacote vendor preservado |
| `xlsx-0.20.3.tgz` | Material/artefato SheetJS redundante; pacote vendor preservado |
| `public/file.svg` | Ícone de template não referenciado |
| `public/globe.svg` | Ícone de template não referenciado |
| `public/window.svg` | Ícone de template não referenciado |
| `examples/d1/app/api/notes/route.ts` | Exemplo sem uso |
| `examples/d1/db/schema.ts` | Exemplo sem uso |
| `enviar-ibagy-v77-github.bat` | Batch antigo enviava diretamente para main |
| `SHA256SUMS.txt` | Inventário do ZIP desatualizado |
| `ARVORE-DE-ARQUIVOS.txt` | Inventário do ZIP desatualizado |
| `vendor/.gitkeep` | Placeholder sem função; vendor possui arquivos |
| `lib/roster.ts` | Helper/adapter/componente sem consumidor; implementações ativas preservadas |
| `lib/supabase-payroll-repository.ts` | Helper/adapter/componente sem consumidor; implementações ativas preservadas |
| `lib/connectors.ts` | Helper/adapter/componente sem consumidor; implementações ativas preservadas |
| `components/connector-error.tsx` | Helper/adapter/componente sem consumidor; implementações ativas preservadas |
| `lib/connector-errors.mts` | Helper/adapter/componente sem consumidor; implementações ativas preservadas |

## Dependências diretas removidas

`@base-ui/react`, `@hookform/resolvers`, `@shadcn/react`, `cmdk`, `date-fns`, `embla-carousel-react`, `input-otp`, `next-themes`, `react-day-picker`, `react-hook-form`, `react-resizable-panels`, `recharts`, `vaul`

React DOM, Radix, SheetJS, Zod, Next e as ferramentas ainda referenciadas foram mantidos. O importer do pnpm-lock.yaml foi sincronizado com package.json sem atualizar versões. As snapshots transitivas antigas do lockfile não foram removidas manualmente; não são imports da aplicação. A tentativa de regeneração offline tentou consultar o registro por política de supply chain e foi interrompida, sem afrouxar a política. A instalação/build na Vercel será a confirmação de compatibilidade.

## Preservados por terem função

- app/, módulos de negócio e autenticação: aplicação e motor v77.
- scripts/test-*, tools/ui-tests e supabase/tests: validação e prevenção de regressões.
- supabase/ e drizzle/: migrações, estrutura e evidência histórica. Não executar tudo indiscriminadamente.
- build/, Vite, Cloudflare, connectors e db/: caminho legado ainda referenciado e ferramentas de execução. Não removê-lo antes de concluir a migração.
- LICENSE e pacote vendor: atribuição e distribuição da biblioteca.
- Documentos de validação anteriores: evidência com data/escopo, não prova de produção pronta.

## Verificação

As dez suítes locais passaram após a limpeza inicial; package.json e o importer do lockfile têm chaves/specifiers iguais. O build Vercel da limpeza inicial (277a1df) ficou READY. A revisão final também removeu cinco helpers/adapters sem consumidor; o build do commit final será conferido antes da entrega. Sem modificação em main e sem liberação de produção.
