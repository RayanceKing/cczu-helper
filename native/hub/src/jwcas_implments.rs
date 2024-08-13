use cczuni::{
    base::{app::AppVisitor, client::Account},
    extension::calendar::{ApplicationCalendarExt, Schedule},
    impls::{
        apps::sso::jwcas::JwcasApplication, client::DefaultClient, login::sso::SSOUniversalLogin,
    },
};

use crate::messages::{
    grades::{GradeData, GradesInput, GradesOutput},
    icalendar::{ICalendarInput, ICalendarOutput},
};

pub async fn generate_icalendar() {
    let mut rev = ICalendarInput::get_dart_signal_receiver().unwrap();
    while let Some(signal) = rev.recv().await {
        let message = signal.message;
        let account = message.account.unwrap();
        let client =
            DefaultClient::new(Account::new(account.user.clone(), account.password.clone()));
        let login = client.sso_universal_login().await;

        if let Err(messgae) = login {
            ICalendarOutput {
                ok: false,
                data: messgae.to_string(),
            }
            .send_signal_to_dart()
        } else {
            let app = client.visit::<JwcasApplication<_>>().await;
            {
                let data = app
                    .generate_icalendar(
                        message.firstweekdate,
                        Schedule::default(),
                        message.reminder,
                    )
                    .await;
                if let Some(calendar) = data {
                    ICalendarOutput {
                        ok: true,
                        data: calendar.to_string(),
                    }
                    .send_signal_to_dart()
                } else {
                    ICalendarOutput {
                        ok: false,
                        data: "生成错误".into(),
                    }
                    .send_signal_to_dart()
                }
            }
        }
    }
}
pub async fn get_grades() {
    let mut rev = GradesInput::get_dart_signal_receiver().unwrap();
    while let Some(signal) = rev.recv().await {
        let message = signal.message;
        let account = message.account.unwrap();
        let client =
            DefaultClient::new(Account::new(account.user.clone(), account.password.clone()));
        let login = client.sso_universal_login().await;
        if let Err(error) = login {
            GradesOutput {
                ok: false,
                data: vec![],
                error: Some(error.to_string()),
            }
            .send_signal_to_dart()
        } else {
            let app = client.visit::<JwcasApplication<_>>().await;
            app.login().await.unwrap();
            let grades = app.get_gradeinfo_vec().await;
            if let Err(error) = grades {
                GradesOutput {
                    ok: false,
                    data: vec![],
                    error: Some(error),
                }
                .send_signal_to_dart();
            } else {
                GradesOutput {
                    ok: true,
                    data: grades
                        .unwrap()
                        .into_iter()
                        .map(|e| GradeData {
                            name: e.name,
                            point: e.point,
                            grade: e.grade,
                        })
                        .collect(),
                    error: None,
                }
                .send_signal_to_dart();
            }
        }
    }
}
