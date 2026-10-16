let localStream,peer,peers={},transcriptText="",recognition;
const videosDiv=document.getElementById('videos'),aiOutput=document.getElementById('ai-output'),summaryBox=document.getElementById('summary-box');
function initSpeech(){
 const SR=window.SpeechRecognition||window.webkitSpeechRecognition;
 if(!SR){aiOutput.textContent="استخدمي Chrome للنسخ";return null}
 const rec=new SR();rec.lang='ar-SA';rec.continuous=true;rec.interimResults=true;
 rec.onresult=(e)=>{let inter="";for(let i=e.resultIndex;i<e.results.length;i++){const t=e.results[i][0].transcript;if(e.results[i].isFinal)transcriptText+=t+" \n";else inter+=t}aiOutput.textContent=transcriptText+"\n..."+inter};
 return rec;
}
document.getElementById('join-btn').onclick=async()=>{
 const roomId=document.getElementById('room-id').value.trim()||'sada-ai-'+Math.floor(Math.random()*1000);
 const username=document.getElementById('username').value.trim()||'مستخدم';
 try{
  localStream=await navigator.mediaDevices.getUserMedia({video:true,audio:true});
  const myId=roomId+'-'+Math.floor(Math.random()*10000);
  peer=new Peer(myId,{config:{iceServers:[{urls:'stun:stun.l.google.com:19302'}]}});
  peer.on('open',()=>{addVideo(localStream,username+' (الوكيل)',true);
   document.getElementById('join-screen').classList.add('hidden');
   document.getElementById('call-screen').classList.remove('hidden');
   document.getElementById('room-info').textContent='الغرفة: '+roomId+' | Sada AI Agent نشط';
   peer.on('call',c=>{c.answer(localStream);c.on('stream',s=>{if(!peers[c.peer])addVideo(s,c.peer);peers[c.peer]=c})});
  });
  peer.on('open',()=>{for(let i=0;i<20;i++){const o=roomId+'-'+i;if(o===myId)continue;const call=peer.call(o,localStream);if(call)call.on('stream',s=>{if(!peers[o])addVideo(s,o);peers[o]=call})}});
  recognition=initSpeech();
 }catch(e){alert('اسمحي بالكاميرا: '+e.message)}
};
function addVideo(s,l,m=false){const w=document.createElement('div');w.className='video-wrapper';const v=document.createElement('video');v.srcObject=s;v.autoplay=true;v.playsInline=true;if(m)v.muted=true;const n=document.createElement('div');n.className='label';n.textContent=l;w.appendChild(v);w.appendChild(n);videosDiv.appendChild(w)}
document.getElementById('transcribe-btn').onclick=()=>{
 if(!recognition)recognition=initSpeech();if(!recognition)return;
 if(document.getElementById('transcribe-btn').dataset.on==='1'){recognition.stop();document.getElementById('transcribe-btn').textContent='🎤 بدء النسخ';document.getElementById('transcribe-btn').dataset.on='0'}else{transcriptText="";recognition.start();document.getElementById('transcribe-btn').textContent='⏹️ ايقاف';document.getElementById('transcribe-btn').dataset.on='1';aiOutput.textContent='🎙️ الوكيل يستمع...'}
};
document.getElementById('summarize-btn').onclick=()=>{
 if(!transcriptText){summaryBox.classList.remove('hidden');summaryBox.textContent='لا يوجد نص';return}
 const sent=transcriptText.split(/[.!?\n]+/).filter(s=>s.trim().length>5);const sum=sent.slice(0,5).join('. ')+'.';
 summaryBox.classList.remove('hidden');summaryBox.innerHTML=`<b>📝 ملخص Sada AI:</b><br><br>${sum}<br><br><small>جاهز للعرض في مسابقة دبي</small>`;
};
document.getElementById('tasks-btn').onclick=()=>{
 if(!transcriptText){summaryBox.classList.remove('hidden');summaryBox.textContent='لا يوجد نص';return}
 const tasks=transcriptText.split('\n').filter(l=>l.length>15).slice(0,5);
 summaryBox.classList.remove('hidden');summaryBox.innerHTML=`<b>✅ مهام مستخرجة:</b><br><br>${tasks.map((t,i)=>`${i+1}. ${t}`).join('<br>')}`;
};
document.getElementById('mute-btn').onclick=()=>{localStream.getAudioTracks().forEach(t=>t.enabled=!t.enabled)};
document.getElementById('video-btn').onclick=()=>{localStream.getVideoTracks().forEach(t=>t.enabled=!t.enabled)};
document.getElementById('leave-btn').onclick=()=>location.reload();
document.getElementById('share-btn').onclick=async()=>{try{const sc=await navigator.mediaDevices.getDisplayMedia({video:true});const tr=sc.getVideoTracks()[0];Object.values(peers).forEach(c=>{const s=c.peerConnection.getSenders().find(x=>x.track&&x.track.kind==='video');if(s)s.replaceTrack(tr)});addVideo(sc,'شاشتك')}catch{}};
