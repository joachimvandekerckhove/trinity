function c = move_to_wdir(options)

origindir = pwd;
c = onCleanup(@()cd(origindir));

cd(options.workingdir)
