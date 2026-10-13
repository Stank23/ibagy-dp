from pathlib import Path
import argparse,base64,html,json,sys
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Table,TableStyle,PageBreak,KeepTogether,Image
from reportlab.graphics.shapes import Drawing,Rect,String,Line,Polygon
from reportlab.graphics import renderSVG
from PIL import Image as PILImage
sys.path.insert(0,str(Path(__file__).parent));from content import DOCS
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'docs';VIS=OUT/'visual';VIS.mkdir(exist_ok=True)
DATE='13/10/2026';RED='#D71920';INK='#171717';MUTED='#526071';BLUE='#145A7C';GREEN='#216446';AMBER='#865E0D'
for name,file in [('Doc','OpenSans-Regular.ttf'),('Doc-Bold','OpenSans-Bold.ttf')]:pdfmetrics.registerFont(TTFont(name,'/usr/share/fonts/truetype/open-sans/'+file))

def figure(kind):
 d=Drawing(495,175);d.add(Rect(0,0,495,175,rx=12,ry=12,fillColor=colors.HexColor('#F5F7FA'),strokeColor=None))
 def box(x,y,w,h,title,sub,color=BLUE):
  d.add(Rect(x,y,w,h,rx=8,ry=8,fillColor=colors.white,strokeColor=colors.HexColor(color),strokeWidth=1.5));d.add(String(x+w/2,y+h-21,title,fontName='Doc-Bold',fontSize=10,fillColor=colors.HexColor(color),textAnchor='middle'))
  for i,line in enumerate(sub.split('|')):d.add(String(x+w/2,y+h-40-i*14,line,fontName='Doc',fontSize=8.3,fillColor=colors.HexColor(INK),textAnchor='middle'))
 def arrow(x1,x2,y):
  d.add(Line(x1,y,x2-6,y,strokeColor=colors.HexColor('#718096'),strokeWidth=1.3));d.add(Polygon([x2,y,x2-6,y+3,x2-6,y-3],fillColor=colors.HexColor('#718096'),strokeColor=None))
 if kind=='palette':
  vals=[('Ação',RED),('Texto',INK),('Fundo','#F6F6F6'),('Painel','#FFFFFF'),('Secundário','#737373'),('Borda','#E5E5E5')]
  for i,(title,code) in enumerate(vals):
   x=15+i*79;d.add(Rect(x,73,67,63,rx=8,ry=8,fillColor=colors.HexColor(code),strokeColor=colors.HexColor('#CFD7E1')));d.add(String(x+33,51,title,fontName='Doc-Bold',fontSize=8.3,textAnchor='middle',fillColor=colors.HexColor(INK)));d.add(String(x+33,33,code,fontName='Doc',fontSize=8,textAnchor='middle',fillColor=colors.HexColor(MUTED)))
 elif kind=='interface':
  box(14,16,467,145,'Cadastro de mensalidade · exemplo fictício','',RED)
  for x,w,label,value in [(29,130,'Participante','Pessoa fictícia'),(171,88,'Integral','R$ 100,00'),(270,89,'Empresa','R$ 30,00'),(370,90,'Líquido','R$ 70,00')]:
   d.add(String(x,111,label,fontName='Doc-Bold',fontSize=9,fillColor=colors.HexColor(MUTED)));d.add(Rect(x,65,w,32,rx=5,ry=5,fillColor=colors.HexColor('#FAFAFA'),strokeColor=colors.HexColor('#D5D5D5')));d.add(String(x+8,77,value,fontName='Doc',fontSize=9,fillColor=colors.HexColor(INK)))
  d.add(String(29,37,'Ilustração do padrão; não é captura do sistema.',fontName='Doc',fontSize=8.5,fillColor=colors.HexColor(MUTED)))
 elif kind=='data':
  for i,(title,sub,col) in enumerate([('employees','Identidade|Matrícula',BLUE),('versions','Vigência mensal|Base de cadastro',GREEN),('records','Fotografia mensal|revision + data',RED)]):
   x=18+i*162;box(x,68,134,78,title,sub,col)
   if i<2:arrow(x+134,x+162,106)
  d.add(String(247,39,'periods controla fechamento • audit registra a operação',fontName='Doc',fontSize=10,fillColor=colors.HexColor(MUTED),textAnchor='middle'));d.add(String(247,20,'Relações lógicas; não é um mapa completo de chaves estrangeiras.',fontName='Doc',fontSize=8,fillColor=colors.HexColor(MUTED),textAnchor='middle'))
 else:
  flows={
   'journey':[('Abrir mês','Competência',BLUE),('Lançar','Cadastro + eventos',RED),('Conferir','Cálculos + histórico',GREEN),('Exportar','Arquivos + fechar',AMBER)],
   'dsr':[('Individual','Cidade + mês',GREEN),('Florianópolis','Padrão herdado',RED),('Geral legado','Fallback preservado',BLUE),('Sugestão','Sem configuração',AMBER)],
   'architecture':[('Navegador','React|Sem chave privada',BLUE),('Proxy / API','Next.js|Vercel',RED),('Serviços','Motor v77|server-only',AMBER),('Supabase','DB + Storage|Transações',GREEN)],
   'transaction':[('Snapshot','Estado + token',BLUE),('Motor v77','Cálculo validado',AMBER),('RPC / CAS','Revisão + bloqueio',RED),('Commit','Dados + auditoria',GREEN)],
   'guardrails':[('Branch','main protegida',RED),('Fictícios','Sem dados reais',BLUE),('Regras v77','Fonte original',AMBER),('Histórico','Não sobrescrever',GREEN)],
   'workflow':[('Ler','Código + referências',BLUE),('Alterar','Escopo autorizado',RED),('Testar','Evidência real',GREEN),('Publicar branch','Documentar limites',AMBER)]}
  for i,(title,sub,col) in enumerate(flows[kind]):
   x=15+i*121;box(x,51,106,95,title,sub,col)
   if i<3:arrow(x+106,x+121,98)
  caption='Prioridade de escolha, da esquerda para a direita.' if kind=='dsr' else 'Fluxo ilustrativo • nenhuma informação pessoal ou credencial.'
  d.add(String(247,24,caption,fontName='Doc',fontSize=8.5,fillColor=colors.HexColor(MUTED),textAnchor='middle'))
 return d

STYLES={
 'title':ParagraphStyle('Title',fontName='Doc-Bold',fontSize=37,leading=43,textColor=colors.HexColor(INK),spaceAfter=14),
 'sub':ParagraphStyle('Sub',fontName='Doc',fontSize=17,leading=24,textColor=colors.HexColor(MUTED),spaceAfter=20),
 'h':ParagraphStyle('Heading',fontName='Doc-Bold',fontSize=21,leading=28,textColor=colors.HexColor(RED),spaceAfter=14),
 'p':ParagraphStyle('Body',fontName='Doc',fontSize=10.3,leading=16,textColor=colors.HexColor(INK),spaceAfter=10),
 'note':ParagraphStyle('Note',fontName='Doc',fontSize=9,leading=13,textColor=colors.HexColor(MUTED),spaceAfter=8),
 'cell':ParagraphStyle('Cell',fontName='Doc',fontSize=8.8,leading=12,textColor=colors.HexColor(INK)),
 'th':ParagraphStyle('TH',fontName='Doc-Bold',fontSize=8.8,leading=12,textColor=colors.white)}

def para(s,key='p'):return Paragraph(escape(s),STYLES[key])
def pdf_table(rows):
 count=len(rows[0]);widths=[511/count]*count
 if count==3:widths=[115,155,241]
 if count==2:widths=[146,365]
 cells=[[para(x,'th' if i==0 else 'cell') for x in row] for i,row in enumerate(rows)];t=Table(cells,colWidths=widths,repeatRows=1,hAlign='LEFT');t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor(RED)),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#F5F7FA')]),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),9),('RIGHTPADDING',(0,0),(-1,-1),9),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),('LINEBELOW',(0,0),(-1,0),1,colors.HexColor(RED)),('LINEBELOW',(0,1),(-1,-1),0.3,colors.HexColor('#DEE4EC'))]));return t

def build_pdf(doc,directory):
 directory.mkdir(parents=True,exist_ok=True);path=directory/(doc['file']+'.pdf')
 logo=ROOT/'public/ibagy-logo.png';story=[];story+=[Spacer(1,35)]
 with PILImage.open(logo) as im:w,h=im.size
 story+=[Image(str(logo),width=155,height=155*h/w,hAlign='LEFT'),Spacer(1,35),para(doc['title'],'title'),para(doc['subtitle'],'sub'),para(doc['intro']),Spacer(1,12),para('Para: '+doc['audience'],'note'),para('Edição 1.0 · '+DATE+' · motor de referência: versão 77','note'),Spacer(1,18)]
 badge=Table([[para('PRÉ-PRODUÇÃO · MIGRAÇÃO EM VALIDAÇÃO','note')]],colWidths=[511]);badge.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#FFF3DD')),('BOX',(0,0),(-1,-1),0.6,colors.HexColor('#DDB36B')),('LEFTPADDING',(0,0),(-1,-1),12),('TOPPADDING',(0,0),(-1,-1),10),('BOTTOMPADDING',(0,0),(-1,-1),6)]));story+=[badge,Spacer(1,22),figure(doc['sections'][0].get('diagram','workflow'))]
 for section in doc['sections']:
  story+=[PageBreak(),para(section['title'],'h')]
  for p in section.get('paragraphs',[]):story.append(para(p))
  if section.get('diagram'):story+=[Spacer(1,5),figure(section['diagram']),Spacer(1,14)]
  if section.get('table'):story+=[pdf_table(section['table']),Spacer(1,12)]
  for n in section.get('notes',[]):story.append(para('Nota · '+n,'note'))
 def page(canvas,document):
  canvas.saveState();canvas.setFillColor(colors.HexColor(RED));canvas.rect(0,A4[1]-9,A4[0],9,fill=1,stroke=0);canvas.setFont('Doc',8);canvas.setFillColor(colors.HexColor(MUTED));canvas.drawString(42,24,'IBAGY DP · '+doc['title']+' · '+DATE);canvas.drawRightString(A4[0]-42,24,str(document.page));canvas.setStrokeColor(colors.HexColor('#DEE4EC'));canvas.line(42,39,A4[0]-42,39);canvas.restoreState()
 SimpleDocTemplate(str(path),pagesize=A4,rightMargin=42,leftMargin=42,topMargin=49,bottomMargin=54,title='IBAGY DP | '+doc['title'],author='IBAGY DP',pageCompression=1).build(story,onFirstPage=page,onLaterPages=page)
 from pdf_ascii import ascii_pdf
 ascii_pdf(path)
 return path

CSS='''*{box-sizing:border-box}body{margin:0;background:#eef1f5;color:#171717;font:16px/1.65 Arial,Helvetica,sans-serif}main{max-width:1000px;margin:32px auto;padding:0 20px}.cover,section{background:white;border-radius:16px;padding:36px 42px;margin:24px 0;border:1px solid #dfe5ec}.cover{border-top:8px solid #d71920}.cover img{width:180px;height:auto}h1{font-size:44px;line-height:1.2;margin:25px 0 10px}h2{font-size:27px;line-height:1.3;color:#b9151c;margin-top:0}.subtitle{font-size:23px;color:#526071}.meta,.note{color:#526071;font-size:14px}.status{display:inline-block;background:#fff3dd;color:#6a4b0c;border:1px solid #ddb36b;border-radius:6px;padding:7px 12px;font-weight:bold}nav a{display:inline-block;margin:6px 18px 6px 0;color:#a51218;text-decoration:underline;text-underline-offset:4px}.figure{margin:24px 0}.figure svg{display:block;max-width:100%;height:auto}table{border-collapse:collapse;width:100%;margin:20px 0;font-size:14px}th{background:#d71920;color:white;text-align:left}td,th{padding:12px;border-bottom:1px solid #dee4ec;vertical-align:top}tr:nth-child(even){background:#f5f7fa}.note{border-left:3px solid #ddb36b;padding:6px 14px;background:#fffbf4}.tablewrap{overflow:auto}@media(max-width:600px){main{padding:0 12px}.cover,section{padding:24px 20px}h1{font-size:32px}h2{font-size:23px}table{min-width:520px}}@media print{body{background:white}main{margin:0;max-width:none}.cover,section{border:0;border-radius:0;page-break-after:always}nav{display:none}table{min-width:0}th{-webkit-print-color-adjust:exact;print-color-adjust:exact}}'''

def build_text(doc):
 md=['# '+doc['title'],'',doc['subtitle'],'',f"**IBAGY DP · {DATE} · edição 1.0 · pré-produção**",'',doc['intro'],'', 'Este documento descreve o sistema e seus limites; não autoriza merge em main ou produção.','']
 logo64=base64.b64encode((ROOT/'public/ibagy-logo.png').read_bytes()).decode();sections=[]
 for i,s in enumerate(doc['sections']):
  md+=['## '+s['title'],'']+s.get('paragraphs',[])+['']
  part='<section id="s'+str(i)+'"><h2>'+html.escape(s['title'])+'</h2>'+''.join('<p>'+html.escape(p)+'</p>' for p in s.get('paragraphs',[]))
  if s.get('diagram'):
   asset=doc['file'].lower()+'-'+s['diagram']+'.svg';svg=renderSVG.drawToString(figure(s['diagram']));svg=svg[svg.index('<svg'):];(VIS/asset).write_text(svg)
   md+=['![Diagrama ilustrativo](visual/'+asset+')',''];part+='<div class="figure" role="img" aria-label="'+html.escape(s['title'])+'">'+svg+'</div>'
  if s.get('table'):
   rows=s['table'];md+=['| '+' | '.join(rows[0])+' |','| '+' | '.join(['---']*len(rows[0]))+' |']+['| '+' | '.join(r)+' |' for r in rows[1:]]+['']
   part+='<div class="tablewrap"><table><thead><tr>'+''.join('<th>'+html.escape(c)+'</th>' for c in rows[0])+'</tr></thead><tbody>'+''.join('<tr>'+''.join('<td>'+html.escape(c)+'</td>' for c in row)+'</tr>' for row in rows[1:])+'</tbody></table></div>'
  for n in s.get('notes',[]):md+=['> '+n,''];part+='<p class="note">'+html.escape(n)+'</p>'
  sections.append(part+'</section>')
 (OUT/(doc['file']+'.md')).write_text('\n'.join(md)+'\n')
 nav=''.join('<a href="#s'+str(i)+'">'+html.escape(s['title'])+'</a>' for i,s in enumerate(doc['sections']))
 page='<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>IBAGY DP · '+html.escape(doc['title'])+'</title><style>'+CSS+'</style></head><body><main><header class="cover"><img alt="IBAGY" src="data:image/png;base64,'+logo64+'"><h1>'+html.escape(doc['title'])+'</h1><p class="subtitle">'+html.escape(doc['subtitle'])+'</p><p>'+html.escape(doc['intro'])+'</p><p class="meta">'+DATE+' · edição 1.0 · '+html.escape(doc['audience'])+'</p><p class="status">Pré-produção · migração em validação</p><nav aria-label="Sumário">'+nav+'</nav></header>'+''.join(sections)+'<footer class="meta">IBAGY DP · branch migracao-vercel-supabase · diagramas ilustrativos e dados fictícios.</footer></main></body></html>'
 (VIS/(doc['file']+'.html')).write_text(page)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--pdf-dir',default=str(ROOT/'work/documentation-output'));args=p.parse_args();directory=Path(args.pdf_dir)
 for doc in DOCS:build_text(doc);path=build_pdf(doc,directory);print(doc['title']+' → '+str(path))
 (VIS/'index.html').write_text('<!doctype html><html lang="pt-BR"><meta charset="utf-8"><title>IBAGY DP · Documentos</title><style>'+CSS+'</style><main><section><h1>Documentos do sistema</h1><p>Pré-produção · '+DATE+'</p>'+''.join('<p><a href="'+d['file']+'.html">'+d['title']+'</a> · '+d['subtitle']+'</p>' for d in DOCS)+'</section></main></html>')
