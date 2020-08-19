function VotingConsensus=vote(E)
%  source: https://github.com/shestakoff/consensus

[n,le]=size(E);
kk=max(max(E,[],1));

VotingConsensus=zeros(n,kk);
P_prev=zeros(n,kk);
for t=1:kk
    idx=find(E(:,1)==t);
    P_prev(idx,t)=1;
end


for m=2:le
    U_cur=zeros(n,kk);
    for t=1:kk
        idx=find(E(:,m)==t);
        U_cur(idx,t)=1;
    end
    CrTbl=P_prev'*U_cur;
    InvCrTbl=repmat(max(max(CrTbl)),kk,kk)-CrTbl;
    [label, cost] = assignmentoptimal(InvCrTbl);
    P_prev=(m-1)*P_prev/m+U_cur(:,label');
end
[temp, VCtemp] = sort(P_prev,2,'descend');

VotingConsensus=VCtemp(:,1);

end
