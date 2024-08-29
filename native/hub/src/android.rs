use cczuni::{
    base::client::Account,
    impls::{
        client::DefaultClient, login::sso::SSOUniversalLogin, services::webvpn::WebVPNService,
    },
};

use crate::messages::vpn::{VpnServiceUserInput, VpnServiceUserOutput};

pub async fn get_vpn_data() {
    let mut rev = VpnServiceUserInput::get_dart_signal_receiver().unwrap();
    while let Some(signal) = rev.recv().await {
        let message = signal.message;
        let account = message.account.unwrap();
        let client =
            DefaultClient::new(Account::new(account.user.clone(), account.password.clone()));
        let login = client.sso_universal_login().await;
        if let Ok(Some(info)) = login {
            let proxy = client.webvpn_get_proxy_service(info.userid.unwrap()).await;
            if let Ok(proxy) = proxy {
                if let Some(data) = proxy.data {
                    VpnServiceUserOutput {
                        ok: true,
                        err: None,
                        token: Some(data.token),
                        dns: Some(data.gateway_list.dns),
                    }
                    .send_signal_to_dart()
                } else {
                    VpnServiceUserOutput {
                        ok: false,
                        err: Some("获取数据为空".into()),
                        token: None,
                        dns: None,
                    }
                    .send_signal_to_dart()
                }
            } else if let Err(message) = proxy {
                VpnServiceUserOutput {
                    ok: false,
                    err: Some(message.to_string()),
                    token: None,
                    dns: None,
                }
                .send_signal_to_dart()
            }
        } else if let Ok(None) = login {
            VpnServiceUserOutput {
                ok: false,
                err: Some("当前正在使用校园网，无需代理".into()),
                token: None,
                dns: None,
            }
            .send_signal_to_dart()
        } else if let Err(message) = login {
            VpnServiceUserOutput {
                ok: false,
                err: Some(message.to_string()),
                token: None,
                dns: None,
            }
            .send_signal_to_dart()
        }
    }
}