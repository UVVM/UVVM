bash uvvm_vvc_framework/internal_script/jenkins-uvvm_vvc_framework-development-simulation.sh
status=$?

bash -ex uvvm_vvc_framework/internal_script/destroy_boxes.sh
destroy_status = $?

if [ $status -eq 0 ];then
status=$destroy_status
fi

exit $status
