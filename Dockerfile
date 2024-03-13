

FROM nginx
RUN mkdir /app
COPY ./dist /app
COPY ./default.conf /etc/nginx/conf.d/default.conf

# 如果端口更换，这边可以更新一下
EXPOSE 80
EXPOSE 6868

# 定义容器启动时执行的命令
CMD ["nginx", "-g", "daemon off;"]
#docker stop ec-admin && docker rm -v ec-admin && docker rmi ec-admin && docker load -i ec-admin.tar && docker run -d --name ec-admin --network host ec-admin
#docker build -t ec-admin . && docker save -o ec-admin.tar ec-admin
#docker save -o ec-admin.tar ec-admin
#docker load -i ec-admin.tar
#docker run -d --name ec-admin --network host ec-admin

#docker cp ec-admin:/etc/nginx/conf.d/default.conf ./
#docker cp ./default.conf ec-admin:/etc/nginx/conf.d/default.conf
#docker cp ./ffeerc.com.pem ec-admin:/app/ffeerc.com.pem