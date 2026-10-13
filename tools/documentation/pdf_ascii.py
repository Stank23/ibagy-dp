"""Serialize generated PDFs as ASCII-safe valid PDF for text-only Git transport.
Font/image streams retain their existing compression with an ASCII85 outer filter.
"""
from pathlib import Path
import base64,io
from pypdf import PdfReader,PdfWriter
from pypdf.generic import StreamObject,NameObject,ArrayObject,NullObject

def ascii_pdf(path):
 reader=PdfReader(path);writer=PdfWriter()
 for page in reader.pages:writer.add_page(page)
 if reader.metadata:writer.add_metadata(dict(reader.metadata))
 for obj in writer._objects:
  if not isinstance(obj,StreamObject):continue
  data=obj._data
  obj._data=base64.a85encode(data,adobe=False)+b'~>'
  old=obj.get('/Filter');filters=list(old) if isinstance(old,ArrayObject) else [old] if old else []
  obj[NameObject('/Filter')]=ArrayObject([NameObject('/ASCII85Decode'),*filters])
  params=obj.get('/DecodeParms')
  if params:obj[NameObject('/DecodeParms')]=ArrayObject([NullObject(),*(list(params) if isinstance(params,ArrayObject) else [params])])
 out=io.BytesIO();writer.write(out);data=out.getvalue().replace(b'%\xe2\xe3\xcf\xd3',b'%ABCD',1)
 data.decode('ascii');path.write_bytes(data)
 check=PdfReader(path);assert len(check.pages)==len(reader.pages)
 for a,b in zip(reader.pages,check.pages):assert a.extract_text()==b.extract_text()
 return len(data)

if __name__=='__main__':
 for p in Path('work/documentation-output').glob('*.pdf'):print(p.name,ascii_pdf(p))
