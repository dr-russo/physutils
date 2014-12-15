function S = simplesyn(t,tau1,tau2)

S = (1-exp(-t/tau1)).*exp(-t/tau2);

end