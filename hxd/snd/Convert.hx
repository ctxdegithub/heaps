package hxd.snd;


class Convert {

	#if (flash && air3)
	static var processing = new Map();
	#end

	static function command(name, args, dstFile) {
		#if (flash && air3)

		if( processing.exists(dstFile) )
			return;
		processing.set(dstFile, true);

		var p = new flash.desktop.NativeProcess();
		var i = new flash.desktop.NativeProcessStartupInfo();
		i.arguments = flash.Vector.ofArray(args);
		var f = flash.filesystem.File.applicationDirectory.resolvePath(name+".exe");
		if( !f.exists ) {
			// TODO : replace with a proper $PATH lookup
			f = new flash.filesystem.File("d:/projects/shiroTools/tools/"+name+".exe");
			if( !f.exists ) throw name+".exe not found : cannot convert wav";
		}
		i.executable = f;
		i.workingDirectory = f.parent;
		p.addEventListener("exit", function(e:Dynamic) {
			processing.remove(dstFile);
			var r : Int = Reflect.field(e, "exitCode");
			if( r != 0 ) {
				var path = try f.nativePath catch( e : Dynamic ) name;
				throw "Failed to run " + path +" " + args.join(" ") + " (Error " + r + ")";
			}
		});
		p.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e) {
		});
		p.start(i);
		#elseif sys
		var r = Sys.command(name, args);
		if( r != 0 )
			throw "Failed to run " + name+" " + args.join(" ") + " (Error " + r + ")";
		#else
		throw "Can't run command on this platform";
		#end
	}

	public static function toMP3( srcFile : String, dstFile : String ) {
		command("lame", ["--resample", "44100", "--silent", "-h", srcFile, dstFile],dstFile);
	}

	public static function toOGG( srcFile : String, dstFile : String ) {
		command("oggenc2", ["--resample", "44100", "-Q", srcFile, "-o", dstFile],dstFile);
	}

}