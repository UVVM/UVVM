
From ubuntu/modelsim:latest
COPY ./ /uvvm/
ENV PATH /root/altera/15.0/modelsim_ase/bin:$PATH
ENV MODELSIM /root/altera/15.0/modelsim_ase/modelsim.ini
WORKDIR /uvvm/bitvis_vip_avalon_mm__backup_simple_access/sim/
CMD ["bash", "-c", "python internal_run.py --clean --no-color --xunit-xml xunit-report.xml"]

