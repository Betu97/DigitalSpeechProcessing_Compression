function [y,LPC] = vocoder_backup(X,order,suv,f0,fs)
    %fer servir order = 13

    Uexc = [];
    Vexc = [];
    [nw, nf] = size(X);
    LPC = zeros(nf, order);
    phase = 0;
    for s = 1:nf
        switch suv(s)
            %silenci
            case 1
                Uexc = [Uexc , zeros(1, nw)];
                Vexc = [Vexc , zeros(1, nw)];
                LPC(s,:) = zeros(order, 1) + 1;
            %sord
            case 2
                [a, g] = lpc(X(:,s), order - 1);
                LPC(s,:) = a;
                Uexc = [Uexc , randn([1 nw]) * sqrt(g)];
                Vexc = [Vexc , zeros(1, nw)];
            %sonor
            case 3
                [a, g] = lpc(X(:,s), order - 1);
                excitation = zeros(nw, 1);
                LPC(s,:) = a;
                period = fs/f0(s);
                time_periods = round((phase:period:(nw - 1)) + 1);
                phase = round(period - (nw - time_periods(end)));
                if isempty(time_periods)
                    phase = phase - nw;
                end
                excitation(time_periods) = excitation(time_periods) + sqrt(g);
                Vexc = [Vexc , excitation.'];
                Uexc = [Uexc , zeros(1, nw)];
        end
    end
    pulse = glotlf(0,(0:50)/50,[0.5 0.055 0.22]);
    Vexc = filter (pulse, 1,Vexc);
    Gexc = (0.04 * Uexc) + (0.96 * Vexc);
    Z = zeros(order - 1, 1);
    y = [];
    for s = 1:nf
        [x, Z] = filter (1, LPC(s,:), Gexc((s - 1) * nw + 1 : s * nw), Z);
        y = [y, x];
    end
end


