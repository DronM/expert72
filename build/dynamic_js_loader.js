	var script_id = window.getApp().getServVar("scriptId");
	var scripts = ["js20/ext/ckeditor5/ckeditor.js"];
	for (var i=0;i<scripts.length;i++){
		var src = scripts[i]+"?"+script_id;
		var res = DOMHelper.getElementsByAttr(src, document.body, "src", true,"script");
		if (!res.length){
			var e = document.createElement("script");
			e.src = src;
			console.log("Added script "+src)		
			document.body.appendChild(e);	
		}
	}

