bash bitvis_uart/internal_script/jenkins-bitvis_uart-encrypted-development-simulation.sh
status=$?

bash -ex bitvis_uart/internal_script/destroy_boxes.sh
destroy_status=$?

if [ $status -eq 0 ];then
status=$destroy_status
fi

exit $status
