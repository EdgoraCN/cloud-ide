'use strict';
if (process.argv.length != 4) {
    console.log("Usage: " + __filename + "   [path of extenstions]  " + "  [dest   list file path]");
    process.exit(-1);
}

var fs = require('fs');

var ext_dir = process.argv[2];
var dest_file=process.argv[3];
console.log("ext_dir:"+ext_dir);
console.log("dest_file:"+dest_file);

if(!fs.existsSync(ext_dir)){
    console.log("ERROR : " + ext_dir + "  not found");
    process.exit(-1);
}
if(fs.existsSync(dest_file)){
    fs.unlink(dest_file, (err) => {
         if (err) throw err;
         console.log(dest_file + 'was deleted');
     });
}
 
fs.readdir(ext_dir, function(err, items) {
    console.log(items);
    var out = fs.createWriteStream(dest_file, {
        flags: 'a' 
      });
    for (var i=0; i<items.length; i++) {
        let packageFile =   ext_dir+'/'+items[i]+'/package.json';
        if(fs.existsSync(packageFile)){
            let rawdata = fs.readFileSync(packageFile);  
            let pkg = JSON.parse(rawdata);  
            let extID  = pkg.publisher + '.' +pkg.name ;
            out.write(extID+'\n');
        }else{
            console.error("ERROR:"+packageFile+" is missing");
        }
    }
    out.end();
});
 