var LibClipboard = {


    HtmlClipboardInit: function () {
		window.addEventListener('paste', (event) => {
			let paste = (event.clipboardData || window.clipboardData).getData('text');
			JsToDef.send("ClipboardPaste", {
				value: paste,
			})
		});
		
    },

}

mergeInto(LibraryManager.library, LibClipboard);