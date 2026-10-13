# Documentos do sistema

content.py é a fonte estruturada dos quatro guias. generate.py produz Markdown, HTML independente com SVG e PDFs com diagramas vetoriais e o logo existente. Nenhuma imagem/captura usa dados reais.

Execute `python tools/documentation/generate.py --pdf-dir docs/downloads`. ReportLab, Pillow e pypdf são dependências apenas da geração editorial, não do build da aplicação; as versões de referência estão em requirements.txt. Os PDFs são entregáveis gerados, não componentes de runtime.

AGENTS.md na raiz é a fonte operacional concisa. Revisar essa fonte e o guia visual juntos. Depois de alterar o conteúdo, regenerar os arquivos e revisar links, páginas, tabelas e diagramas.
