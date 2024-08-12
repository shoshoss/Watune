var e;(function(e){e.LOAD="LOAD";e.EXEC="EXEC";e.WRITE_FILE="WRITE_FILE";e.READ_FILE="READ_FILE";e.DELETE_FILE="DELETE_FILE";e.RENAME="RENAME";e.CREATE_DIR="CREATE_DIR";e.LIST_DIR="LIST_DIR";e.DELETE_DIR="DELETE_DIR";e.ERROR="ERROR";e.DOWNLOAD="DOWNLOAD";e.PROGRESS="PROGRESS";e.LOG="LOG";e.MOUNT="MOUNT";e.UNMOUNT="UNMOUNT"})(e||(e={}));const t=(()=>{let e=0;return()=>e++})();new Error("unknown message type");const s=new Error("ffmpeg is not loaded, call `await ffmpeg.load()` first");const r=new Error("called FFmpeg.terminate()");new Error("failed to import ffmpeg-core.js");class FFmpeg{#e=null;#t={};#s={};#r=[];#a=[];loaded=false;#o=()=>{this.#e&&(this.#e.onmessage=({data:{id:t,type:s,data:r}})=>{switch(s){case e.LOAD:this.loaded=true;this.#t[t](r);break;case e.MOUNT:case e.UNMOUNT:case e.EXEC:case e.WRITE_FILE:case e.READ_FILE:case e.DELETE_FILE:case e.RENAME:case e.CREATE_DIR:case e.LIST_DIR:case e.DELETE_DIR:this.#t[t](r);break;case e.LOG:this.#r.forEach((e=>e(r)));break;case e.PROGRESS:this.#a.forEach((e=>e(r)));break;case e.ERROR:this.#s[t](r);break}delete this.#t[t];delete this.#s[t]})};#i=({type:e,data:r},a=[],o)=>this.#e?new Promise(((s,i)=>{const E=t();this.#e&&this.#e.postMessage({id:E,type:e,data:r},a);this.#t[E]=s;this.#s[E]=i;o?.addEventListener("abort",(()=>{i(new DOMException(`Message # ${E} was aborted`,"AbortError"))}),{once:true})})):Promise.reject(s);on(e,t){e==="log"?this.#r.push(t):e==="progress"&&this.#a.push(t)}off(e,t){e==="log"?this.#r=this.#r.filter((e=>e!==t)):e==="progress"&&(this.#a=this.#a.filter((e=>e!==t)))}
/**
     * Loads ffmpeg-core inside web worker. It is required to call this method first
     * as it initializes WebAssembly and other essential variables.
     *
     * @category FFmpeg
     * @returns `true` if ffmpeg core is loaded for the first time.
     */load=({classWorkerURL:t,...s}={},{signal:r}={})=>{if(!this.#e){this.#e=t?new Worker(new URL(t,import.meta.url),{type:"module"}):new Worker(new URL("./worker.js",import.meta.url),{type:"module"});this.#o()}return this.#i({type:e.LOAD,data:s},void 0,r)};
/**
     * Execute ffmpeg command.
     *
     * @remarks
     * To avoid common I/O issues, ["-nostdin", "-y"] are prepended to the args
     * by default.
     *
     * @example
     * ```ts
     * const ffmpeg = new FFmpeg();
     * await ffmpeg.load();
     * await ffmpeg.writeFile("video.avi", ...);
     * // ffmpeg -i video.avi video.mp4
     * await ffmpeg.exec(["-i", "video.avi", "video.mp4"]);
     * const data = ffmpeg.readFile("video.mp4");
     * ```
     *
     * @returns `0` if no error, `!= 0` if timeout (1) or error.
     * @category FFmpeg
     */
exec=(t,s=-1,{signal:r}={})=>this.#i({type:e.EXEC,data:{args:t,timeout:s}},void 0,r);terminate=()=>{const e=Object.keys(this.#s);for(const t of e){this.#s[t](r);delete this.#s[t];delete this.#t[t]}if(this.#e){this.#e.terminate();this.#e=null;this.loaded=false}};writeFile=(t,s,{signal:r}={})=>{const a=[];s instanceof Uint8Array&&a.push(s.buffer);return this.#i({type:e.WRITE_FILE,data:{path:t,data:s}},a,r)};mount=(t,s,r)=>{const a=[];return this.#i({type:e.MOUNT,data:{fsType:t,options:s,mountPoint:r}},a)};unmount=t=>{const s=[];return this.#i({type:e.UNMOUNT,data:{mountPoint:t}},s)};readFile=(t,s="binary",{signal:r}={})=>this.#i({type:e.READ_FILE,data:{path:t,encoding:s}},void 0,r);deleteFile=(t,{signal:s}={})=>this.#i({type:e.DELETE_FILE,data:{path:t}},void 0,s);rename=(t,s,{signal:r}={})=>this.#i({type:e.RENAME,data:{oldPath:t,newPath:s}},void 0,r);createDir=(t,{signal:s}={})=>this.#i({type:e.CREATE_DIR,data:{path:t}},void 0,s);listDir=(t,{signal:s}={})=>this.#i({type:e.LIST_DIR,data:{path:t}},void 0,s);deleteDir=(t,{signal:s}={})=>this.#i({type:e.DELETE_DIR,data:{path:t}},void 0,s)}export{FFmpeg};

