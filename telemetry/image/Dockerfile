FROM grafana/grafana:12.0.2
COPY --chown=grafana:grafana files/st.json /var/lib/grafana/dashboards/st.json
COPY --chown=grafana:grafana files/volkovlabs-variable-panel /var/lib/grafana/plugins/volkovlabs-variable-panel
COPY --chown=grafana:grafana files/andrewbmchugh-flow-panel /var/lib/grafana/plugins/andrewbmchugh-flow-panel
