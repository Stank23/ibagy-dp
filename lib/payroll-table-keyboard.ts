/** Horizontal navigation only for a visible payroll table outside editing controls. */
export function scrollPayrollTable(event:KeyboardEvent,container:HTMLElement|null):void {
 if(!container||!container.getClientRects().length||event.defaultPrevented||event.isComposing||event.altKey||event.ctrlKey||event.metaKey||event.shiftKey||!['ArrowLeft','ArrowRight'].includes(event.key))return;
 const target=event.target instanceof Element?event.target:null;
 if(target?.closest('input,textarea,select,[contenteditable]:not([contenteditable="false"]),[role="combobox"],[role="listbox"],[role="slider"],[role="spinbutton"],[role="tablist"],[role="radio"],[role="checkbox"]'))return;
 if([...container.ownerDocument.querySelectorAll('[role="dialog"],[role="alertdialog"]')].some(dialog=>dialog.getClientRects().length))return;
 const max=Math.max(0,container.scrollWidth-container.clientWidth);
 const next=Math.max(0,Math.min(max,container.scrollLeft+(event.key==='ArrowRight'?120:-120)));
 if(next===container.scrollLeft)return;
 event.preventDefault();container.scrollTo({left:next,behavior:'instant'});
}
