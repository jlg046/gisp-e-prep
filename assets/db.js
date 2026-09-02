
(function(){
  const STUDENT_TOKEN_KEY='gispe_student_session_v2';
  const ADMIN_TOKEN_KEY='gispe_admin_session_v2';
  function configured(){
    const c=window.GISPE_CONFIG||{};
    return c.supabaseUrl && !c.supabaseUrl.includes('PASTE_') &&
           c.supabasePublishableKey && !c.supabasePublishableKey.includes('PASTE_');
  }
  function client(){
    if(!configured()) throw new Error('Supabase is not configured. Edit assets/config.js.');
    return window.supabase.createClient(window.GISPE_CONFIG.supabaseUrl, window.GISPE_CONFIG.supabasePublishableKey);
  }
  async function rpc(name,args={}){
    const {data,error}=await client().rpc(name,args);
    if(error) throw error;
    return data;
  }
  async function studentLogin(username,pin){
    const data=await rpc('student_login',{p_username:username,p_pin:pin});
    if(!data || !data.ok) throw new Error(data?.message||'Login failed.');
    localStorage.setItem(STUDENT_TOKEN_KEY,data.token);
    localStorage.setItem('gispe_student_name_v2',data.display_name||username);
    localStorage.setItem('gispe_student_username_v2',data.username||username);
    return data;
  }
  async function studentProfile(){
    const token=localStorage.getItem(STUDENT_TOKEN_KEY);
    if(!token) return null;
    const data=await rpc('student_session_profile',{p_token:token});
    if(!data || !data.ok){ studentLogout(); return null; }
    return data;
  }
  async function studentAttempts(){
    const token=localStorage.getItem(STUDENT_TOKEN_KEY);
    if(!token) return [];
    return await rpc('student_attempts',{p_token:token}) || [];
  }
  async function saveAttempt(payload){
    const token=localStorage.getItem(STUDENT_TOKEN_KEY);
    if(!token) throw new Error('Student is not logged in.');
    return await rpc('student_save_attempt',{
      p_token:token,
      p_exam_version:payload.version,
      p_exam_set:payload.examSet || Math.ceil(payload.version/3),
      p_difficulty:payload.difficulty || 'Standard',
      p_difficulty_code:payload.difficultyCode || 'A',
      p_completed_at:payload.completedAt,
      p_raw_correct:payload.rawCorrect,
      p_raw_percent:payload.rawPercent,
      p_weighted_score:payload.weightedScore,
      p_domains:payload.domains,
      p_remediation:payload.remediation||[]
    });
  }
  async function studentLogout(){
    const token=localStorage.getItem(STUDENT_TOKEN_KEY);
    try{ if(token && configured()) await rpc('student_logout',{p_token:token}); }catch(e){}
    localStorage.removeItem(STUDENT_TOKEN_KEY);
    localStorage.removeItem('gispe_student_name_v2');
    localStorage.removeItem('gispe_student_username_v2');
  }
  async function adminLogin(pin){
    const data=await rpc('admin_login',{p_pin:pin});
    if(!data || !data.ok) throw new Error(data?.message||'Admin login failed.');
    localStorage.setItem(ADMIN_TOKEN_KEY,data.token);
    return data;
  }
  async function adminValid(){
    const token=localStorage.getItem(ADMIN_TOKEN_KEY);
    if(!token) return false;
    const data=await rpc('admin_session_valid',{p_token:token});
    if(!data || !data.ok){ localStorage.removeItem(ADMIN_TOKEN_KEY); return false; }
    return true;
  }
  async function adminStudents(){return await rpc('admin_students',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY)})||[]}
  async function adminAttempts(){return await rpc('admin_attempts',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY)})||[]}
  async function adminCreateStudent(x){return await rpc('admin_create_student',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY),p_username:x.username,p_pin:x.pin,p_display_name:x.displayName,p_cohort:x.cohort||''})}
  async function adminResetPin(studentId,newPin){return await rpc('admin_reset_student_pin',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY),p_student_id:studentId,p_new_pin:newPin})}
  async function adminSetActive(studentId,active){return await rpc('admin_set_student_active',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY),p_student_id:studentId,p_active:active})}
  async function adminUpdateCohort(studentId,cohort){return await rpc('admin_update_student_cohort',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY),p_student_id:studentId,p_cohort:cohort||''})}
  async function adminDeleteAttempt(attemptId){return await rpc('admin_delete_attempt',{p_token:localStorage.getItem(ADMIN_TOKEN_KEY),p_attempt_id:attemptId})}
  function adminLogout(){localStorage.removeItem(ADMIN_TOKEN_KEY)}
  window.GISPEDB={configured,studentLogin,studentProfile,studentAttempts,saveAttempt,studentLogout,adminLogin,adminValid,adminStudents,adminAttempts,adminCreateStudent,adminResetPin,adminSetActive,adminUpdateCohort,adminDeleteAttempt,adminLogout};
})();
