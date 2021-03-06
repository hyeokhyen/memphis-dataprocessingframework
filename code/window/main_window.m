function main_window(G,pid, sid,INDIR,OUTDIR,MODEL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Copyright 2014 University of Memphis
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%
%% Load Basic Feature Data
fprintf('%-6s %-6s %-20s Task (',pid,sid,'main_window');
indir=[G.DIR.DATA G.DIR.SEP INDIR];
infile=[pid '_' sid '_' G.FILE.BASICFEATURE_MATNAME];
outdir=[G.DIR.DATA G.DIR.SEP OUTDIR];
outfile=[MODEL.STUDYTYPE '_' pid '_' sid '_' MODEL.NAME '_' G.FILE.WINDOW_MATNAME];

load ([indir G.DIR.SEP infile]);
if G.RUN.WINDOW.LOADDATA==1 && exist([outdir G.DIR.SEP outfile],'file')==2
    load([outdir G.DIR.SEP outfile]);
else
    W=B;
end

W.NAME=['WINDOW[' G.STUDYNAME ' ' pid ' ' sid ']'];

%% Normalize before windowing
if isfield(MODEL,'NORMALIZE') && isfield(MODEL.NORMALIZE,'SENSOR') && isfield(MODEL.NORMALIZE.SENSOR,'WINSORIZE')
    for i=size(MODEL.NORMALIZE.SENSOR.WINSORIZE,1)
        SENSORID=MODEL.NORMALIZE.SENSOR.WINSORIZE(i,1);
        WINLEN=MODEL.NORMALIZE.SENSOR.WINSORIZE(i,2);
        B.sensor{SENSORID}.sample=local_winsorize(B.sensor{SENSORID}.sample,B.sensor{SENSORID}.timestamp,WINLEN);
    end
end
if isfield(MODEL,'NORMALIZE') && isfield(MODEL.NORMALIZE,'RR')
        WINLEN=MODEL.NORMALIZE.RR;
        ind=find(B.sensor{G.SENSOR.R_ECGID}.rr.quality==G.QUALITY.GOOD);
        B.sensor{G.SENSOR.R_ECGID}.rr.sample(ind)=local_winsorize(B.sensor{G.SENSOR.R_ECGID}.rr.sample(ind),B.sensor{G.SENSOR.R_ECGID}.rr.timestamp(ind),WINLEN);
end


%% Segmentation
if isfield(W,'sensor'), W=rmfield(W,'sensor');end;
if strcmp(MODEL.WINDOWTYPE,'cycle')
    W=segmentbycycle(G,MODEL);
elseif strcmp(MODEL.WINDOWTYPE,'time')
    W.window=segmentinwindow(G,B.sensor,B.starttimestamp,B.endtimestamp,MODEL);
end;

if isempty(dir(outdir))
    mkdir(outdir);
end

save([outdir G.DIR.SEP outfile],'W');
