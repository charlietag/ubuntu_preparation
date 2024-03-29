# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable


# ======= Define Var ===========
local service_name=""

# ======= Define Var ===========

echo "================================"
echo "    Toggling Services"
echo "================================"
echo "${toggle}: ---------------->"
echo "${toggle_services[@]}"

if [ "${toggle}" == "enable" ]
then
  systemctl enable ${toggle_services[@]}
  systemctl start ${toggle_services[@]}
else
  systemctl disable ${toggle_services[@]}
  systemctl stop ${toggle_services[@]}
fi

echo "${toggle}: ----------------> done"
# for toggle_service in ${toggle_services[@]}
# do
#   service_name="${toggle_service}.service"
#   echo ""
#   echo "------------------------------------------"
#   echo "systemctl ${toggle} \"${service_name}\""
#   echo "------------------------------------------"
#
#   if [ "${toggle}" == "enable" ]
#   then
#     systemctl enable ${service_name}
#     systemctl start ${service_name}
#   else
#     systemctl disable ${service_name}
#     systemctl stop ${service_name}
#   fi
# done
