bash uvvm_util/internal_script/jenkins-uvvm_util-development-simulation.sh
status=$?

bash -ex uvvm_util/internal_script/destroy_boxes.sh
destroy_status=$?

if [ $status -eq 0 ];then
status=$destroy_status
fi

exit $status
