startup;
load activations.mat

numpos = conf.train.pid_end - conf.train.pid_start+1;
numneg = conf.train.nid_end - conf.train.nid_start+1;

n = conf.model.kmeansk;

X = activations(:,1:numpos);
Y = activations(:, numpos+1:end);

% load data and clear mmweight in case already exists
load sandbox_train.mat
for ii = 1 : conf.model.kmeansk
    votes(ii).mmweight = [];
end

for ii = 1 : length(conf.model.bigc)
    g = conf.model.bigc(ii);

    % Solution via CVX
    %           minimize    1'*u + 1'*v
    %               s.t.    a'*x_i - b >= 1 - u_i        for i = 1,...,N
    %                       a'*y_i - b <= -(1 - v_i)     for i = 1,...,M
    %                       u >= 0 and v >= 0 and a >= 0
    cvx_begin
        variables a(n) b(1) u(numpos) v(numneg)
        minimize (norm(a) + g*(ones(1,numpos)*u + ones(1,numneg)*v))
        X'*a - b >= 1 - u;
        Y'*a - b <= -(1 - v);
        u >= 0;
        v >= 0;
        a >= 0;
    cvx_end

    % max-margin weight  must be positive
    a(a<0) = 0;

    % save discriminatively trained weights
    for ii = 1 : conf.model.kmeansk
        votes(ii).mmweight = [votes(ii).mmweight a(ii)];
    end
    save('sandbox_train.mat','data','gbdesc','gbpos','kmc', 'kmidx', 'votes');
end