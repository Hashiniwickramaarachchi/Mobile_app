import { useMemo, useState } from "react";

const initialAlerts = [
  {
    id: 1,
    type: "Inactivity Alert",
    status: "pending",
    severity: "medium",
    occurredAt: "2026-04-25T23:02:00",
    incidentDetail: "Inactivity detected in 2+ hours."
  },
  {
    id: 2,
    type: "Fall Detected",
    status: "pending",
    severity: "high",
    occurredAt: "2026-04-25T21:44:00",
    incidentDetail: "Fall detected in the hallway. Subject remained on floor."
  },
  {
    id: 3,
    type: "Wandering Alert",
    status: "pending",
    severity: "high",
    occurredAt: "2026-04-25T20:16:00",
    incidentDetail: "Repeated pacing detected in an unusual pattern."
  }
];

const initialNotificationState = {
  fallDetected: true,
  inactivity: true,
  wandering: true
};

const defaultProfile = {
  guardianName: "James Johnson",
  elderlyName: "Margaret Johnson",
  age: "72",
  disabilities: "Diabetes, blood pressure medication",
  emergencyContacts: [
    { id: "c1", name: "Dr. Sarah Williams", phone: "+1 234 987 1234", relationship: "Primary Doctor" },
    { id: "c2", name: "Mary Johnson", phone: "+1 234 876 2210", relationship: "Daughter" }
  ]
};

function App() {
  const [isAuthenticated, setAuthenticated] = useState(false);
  const [authView, setAuthView] = useState("login");
  const [signupSuccess, setSignupSuccess] = useState("");
  const [alerts, setAlerts] = useState(initialAlerts);
  const [accountProfile, setAccountProfile] = useState(defaultProfile);
  const [notifications, setNotifications] = useState(initialNotificationState);
  const [alertFilter, setAlertFilter] = useState("all");
  const [tab, setTab] = useState("home");
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [dialNumber, setDialNumber] = useState("");
  const [dialPadBackTab, setDialPadBackTab] = useState("home");

  const activeAlert = useMemo(() => alerts.find((alert) => alert.id === selectedAlert) ?? null, [alerts, selectedAlert]);
  const latestAlertTime = useMemo(() => {
    if (!alerts.length) {
      return "";
    }
    return alerts.reduce((latest, current) => (new Date(current.occurredAt) > new Date(latest.occurredAt) ? current : latest)).occurredAt;
  }, [alerts]);

  if (!isAuthenticated) {
    if (authView === "signup") {
      return (
        <SignUpScreen
          onBackToLogin={() => setAuthView("login")}
          onSubmit={() => {
            setSignupSuccess("Account created. Please sign in.");
            setAuthView("login");
          }}
          onSaveProfile={(form) => setAccountProfile(mapSignUpToProfile(form))}
        />
      );
    }

    return (
      <LoginScreen
        successMessage={signupSuccess}
        onSignIn={() => setAuthenticated(true)}
        onOpenSignUp={() => {
          setSignupSuccess("");
          setAuthView("signup");
        }}
      />
    );
  }

  return (
    <div className="app-shell">
      <div className="phone-frame">
        {tab === "home" && (
          <HomeScreen
            alertsCount={alerts.filter((item) => item.status === "pending").length}
            profile={accountProfile}
            lastActivityTime={formatOnlyTime(latestAlertTime)}
            onEmergencyClick={() => {
              setDialNumber("");
              setDialPadBackTab("home");
              setTab("dialpad");
            }}
            onCall1990Click={() => {
              setDialNumber("1990");
              setDialPadBackTab("home");
              setTab("dialpad");
            }}
            onAlertsClick={() => setTab("alerts")}
            onOpenProfile={() => setTab("profile")}
          />
        )}
        {tab === "alerts" && (
          <AlertsScreen
            alerts={alerts}
            filter={alertFilter}
            onFilterChange={setAlertFilter}
            onOpenAlert={(id) => {
              setSelectedAlert(id);
              setTab("alert-detail");
            }}
          />
        )}
        {tab === "alert-detail" && activeAlert && (
          <AlertDetailScreen
            alert={activeAlert}
            onBack={() => setTab("alerts")}
            onHandleEmergency={() => setTab("emergency-actions")}
            onStatusChecked={() => {
              setAlerts((prev) =>
                prev.map((alert) => (alert.id === activeAlert.id ? { ...alert, status: "checked" } : alert))
              );
            }}
          />
        )}
        {tab === "emergency-actions" && (
          <EmergencyActionsScreen
            onBack={() => setTab("alert-detail")}
            onAction={(number) => {
              setDialNumber(number);
              setDialPadBackTab("emergency-actions");
              setTab("dialpad");
            }}
          />
        )}
        {tab === "settings" && (
          <SettingsScreen
            profile={accountProfile}
            notifications={notifications}
            onToggleNotification={(key) =>
              setNotifications((prev) => ({ ...prev, [key]: !prev[key] }))
            }
            onSignOut={() => {
              setAuthenticated(false);
              setAuthView("login");
              setTab("home");
            }}
            onSaveProfile={setAccountProfile}
          />
        )}
        {tab === "profile" && (
          <ProfileScreen
            profile={accountProfile}
            onSaveProfile={setAccountProfile}
            onBack={() => setTab("home")}
            onOpenSettings={() => setTab("settings")}
          />
        )}
        {tab === "dialpad" && (
          <DialPadScreen
            number={dialNumber}
            onChangeNumber={setDialNumber}
            onBack={() => setTab(dialPadBackTab)}
          />
        )}

        {(tab === "home" || tab === "alerts" || tab === "settings") && (
          <BottomNav
            tab={tab}
            onChange={setTab}
          />
        )}
      </div>
    </div>
  );
}

function LoginScreen({ onSignIn, onOpenSignUp, successMessage }) {
  return (
    <div className="app-shell">
      <div className="phone-frame login">
        <div className="logo-block">S</div>
        <h1>SafeGuard</h1>
        <p className="muted">Welcome back</p>
        {successMessage ? <p className="success-message">{successMessage}</p> : null}
        <div className="form-grid">
          <input placeholder="Email" />
          <input placeholder="Password" type="password" />
        </div>
        <button className="btn btn-primary full" onClick={onSignIn}>Sign In</button>
        <p className="signup-text">
          Don&apos;t have any account?{" "}
          <button className="inline-link" onClick={onOpenSignUp}>
            <strong>Sign up</strong>
          </button>
        </p>
      </div>
    </div>
  );
}

function SignUpScreen({ onBackToLogin, onSubmit, onSaveProfile }) {
  const [form, setForm] = useState({
    guardianName: "",
    elderlyName: "",
    age: "",
    disabilities: "",
    emergencyContact1Name: "",
    emergencyContact1Phone: "",
    emergencyContact2Name: "",
    emergencyContact2Phone: ""
  });

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    onSaveProfile(form);
    onSubmit(form);
  };

  return (
    <div className="app-shell">
      <div className="phone-frame signup-screen">
        <section className="screen">
          <header className="screen-header">
            <button className="back-icon-btn" onClick={onBackToLogin} aria-label="Back">
              ←
            </button>
            <h2>Sign Up</h2>
            <p className="muted">Enter guardian, elderly and emergency details</p>
          </header>

          <form className="form-grid" onSubmit={handleSubmit}>
            <label className="field-label">
              Guardian Name
              <input name="guardianName" value={form.guardianName} onChange={handleChange} required />
            </label>
            <label className="field-label">
              Elderly Person Name
              <input name="elderlyName" value={form.elderlyName} onChange={handleChange} required />
            </label>
            <label className="field-label">
              Age
              <input name="age" type="number" min="1" value={form.age} onChange={handleChange} required />
            </label>
            <label className="field-label">
              Disabilities
              <input name="disabilities" value={form.disabilities} onChange={handleChange} placeholder="e.g. mobility issue, hearing issue" required />
            </label>
            <label className="field-label">
              1st Emergency Contact Name
              <input name="emergencyContact1Name" value={form.emergencyContact1Name} onChange={handleChange} required />
            </label>
            <label className="field-label">
              1st Emergency Contact Phone Number
              <input name="emergencyContact1Phone" value={form.emergencyContact1Phone} onChange={handleChange} required />
            </label>
            <label className="field-label">
              2nd Emergency Contact Name
              <input name="emergencyContact2Name" value={form.emergencyContact2Name} onChange={handleChange} required />
            </label>
            <label className="field-label">
              2nd Emergency Contact Phone Number
              <input name="emergencyContact2Phone" value={form.emergencyContact2Phone} onChange={handleChange} required />
            </label>

            <button className="btn btn-primary full" type="submit">Create Account</button>
          </form>
        </section>
      </div>
    </div>
  );
}

function HomeScreen({ alertsCount, profile, lastActivityTime, onEmergencyClick, onCall1990Click, onAlertsClick, onOpenProfile }) {
  const greeting = getGreetingMessage();

  return (
    <section className="screen">
      <header className="screen-header home-header">
        <div className="home-header-text">
          <p className="greeting-text">{greeting}</p>
          <h2>SafeGuard Monitor</h2>
        </div>
        <button className="profile-icon-btn" onClick={onOpenProfile} aria-label="Open profile">
          👤
        </button>
      </header>
      <article className="card profile">
        <strong>{profile.elderlyName}</strong>
        <span>Age: {profile.age}</span>
      </article>
      <article className="card status safe">
        <strong>Safe</strong>
        <span>Last activity: {lastActivityTime}</span>
      </article>
      <div className="quick-actions">
        <button className="pill danger" onClick={onEmergencyClick}>
          <span className="btn-icon" aria-hidden="true">🚨</span>
          <span>Emergency</span>
        </button>
        <button className="pill" onClick={onCall1990Click}>
          <span className="btn-icon" aria-hidden="true">📞</span>
          <span>Call 1990</span>
        </button>
        <button className="pill warn" onClick={onAlertsClick}>
          <span className="btn-icon" aria-hidden="true">🔔</span>
          <span>Alerts ({alertsCount})</span>
        </button>
      </div>
      <article className="card camera">
        <strong>Live Camera</strong>
        <div className="camera-box">Camera preview placeholder</div>
      </article>
    </section>
  );
}

function ProfileScreen({ profile, onSaveProfile, onBack, onOpenSettings }) {
  const [isEditing, setEditing] = useState(false);
  const [draft, setDraft] = useState({
    guardianName: profile.guardianName,
    elderlyName: profile.elderlyName,
    age: profile.age,
    disabilities: profile.disabilities
  });

  const saveProfile = () => {
    onSaveProfile({ ...profile, ...draft });
    setEditing(false);
  };

  return (
    <section className="screen">
      <button className="back-icon-btn" onClick={onBack} aria-label="Back">
        ←
      </button>
      <header className="screen-header row-between">
        <h2>Profile</h2>
        {isEditing ? (
          <button className="text-btn" onClick={saveProfile}>Save</button>
        ) : (
          <button className="icon-btn edit-icon" title="Edit profile" aria-label="Edit profile" onClick={() => setEditing(true)}>✏️</button>
        )}
      </header>
      <article className="card">
        <strong>Guardian</strong>
        {isEditing ? (
          <input value={draft.guardianName} onChange={(event) => setDraft((prev) => ({ ...prev, guardianName: event.target.value }))} />
        ) : (
          <span>{profile.guardianName}</span>
        )}
      </article>
      <article className="card">
        <strong>Elderly</strong>
        {isEditing ? (
          <div className="form-grid compact">
            <input value={draft.elderlyName} onChange={(event) => setDraft((prev) => ({ ...prev, elderlyName: event.target.value }))} />
            <input value={draft.age} onChange={(event) => setDraft((prev) => ({ ...prev, age: event.target.value }))} />
            <input value={draft.disabilities} onChange={(event) => setDraft((prev) => ({ ...prev, disabilities: event.target.value }))} />
          </div>
        ) : (
          <>
            <span>{profile.elderlyName}</span>
            <span>Age: {profile.age}</span>
            <span>{profile.disabilities}</span>
          </>
        )}
      </article>
      <article className="card">
        <strong>Emergency Contacts</strong>
        {profile.emergencyContacts.map((contact) => (
          <div key={contact.id}>
            <span>{contact.name} - {contact.phone}</span>
          </div>
        ))}
      </article>
      <button className="btn btn-primary full" onClick={onOpenSettings}>Open Settings</button>
    </section>
  );
}

function DialPadScreen({ number, onChangeNumber, onBack }) {
  const dialKeys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"];

  return (
    <section className="screen dialpad-screen">
      <button className="back-icon-btn" onClick={onBack} aria-label="Back">
        ←
      </button>
      <div className="dial-number">{number || "Enter number"}</div>
      <div className="dial-grid">
        {dialKeys.map((key) => (
          <button
            key={key}
            className="dial-key"
            onClick={() => onChangeNumber((prev) => prev + key)}
          >
            {key}
          </button>
        ))}
      </div>
      <div className="dial-actions">
        <button className="dial-action dial-delete" onClick={() => onChangeNumber((prev) => prev.slice(0, -1))}>
          ⌫
        </button>
        <button className="dial-action dial-call">
          📞
        </button>
      </div>
    </section>
  );
}

function AlertsScreen({ alerts, filter, onFilterChange, onOpenAlert }) {
  const filteredAlerts = filter === "all" ? alerts : alerts.filter((alert) => alert.status === filter);

  return (
    <section className="screen">
      <header className="screen-header">
        <h2>Alerts</h2>
      </header>
      <div className="alert-filters">
        <button className={filter === "all" ? "active" : ""} onClick={() => onFilterChange("all")}>All</button>
        <button className={filter === "pending" ? "active" : ""} onClick={() => onFilterChange("pending")}>Pending</button>
        <button className={filter === "checked" ? "active" : ""} onClick={() => onFilterChange("checked")}>Checked</button>
      </div>
      <div className="alert-list">
        {filteredAlerts.map((alert) => (
          <button key={alert.id} className="alert-row" onClick={() => onOpenAlert(alert.id)}>
            <div>
              <strong>{alert.type}</strong>
              <span>{formatAlertDate(alert.occurredAt)}</span>
            </div>
            <span className={`status-tag ${alert.status}`}>{alert.status}</span>
          </button>
        ))}
      </div>
    </section>
  );
}

function AlertDetailScreen({ alert, onBack, onHandleEmergency, onStatusChecked }) {
  return (
    <section className="screen">
      <button className="back-icon-btn" onClick={onBack} aria-label="Back">
        ←
      </button>
      <h2 className="detail-title">{alert.type}</h2>
      <p className="muted detail-date">{formatAlertDate(alert.occurredAt)}</p>
      <div className="detail-metrics">
        <article className="card detail-card">
          <span>Severity</span>
          <strong className={alert.severity}>{alert.severity}</strong>
        </article>
        <article className="card detail-card">
          <span>Status</span>
          <strong>{alert.status}</strong>
        </article>
      </div>
      <article className="card camera">
        <strong>Camera Snapshot</strong>
        <div className="camera-box">Image area</div>
      </article>
      <article className="card incident-card">
        <strong>Incident Detail</strong>
        <span>{alert.incidentDetail}</span>
      </article>
      {alert.status === "pending" ? (
        <>
          <button className="btn btn-ghost full" onClick={onStatusChecked}>Status Checked</button>
          <button className="btn btn-danger full" onClick={onHandleEmergency}>Handle Emergency</button>
        </>
      ) : null}
    </section>
  );
}

function EmergencyActionsScreen({ onBack, onAction }) {
  return (
    <section className="screen">
      <button className="back-icon-btn" onClick={onBack} aria-label="Back">
        ←
      </button>
      <h2>Emergency Actions</h2>
      <button className="btn btn-primary full" onClick={() => onAction("0771234567")}>Call Emergency Contact</button>
      <button className="btn btn-danger full" onClick={() => onAction("1990")}>Call Ambulance</button>
      <button className="btn btn-warn full" onClick={() => onAction("1990")}>Call 1990 Hotline</button>
    </section>
  );
}

function SettingsScreen({ profile, notifications, onToggleNotification, onSignOut, onSaveProfile }) {
  const [isEditingProfile, setEditingProfile] = useState(false);
  const [draftProfile, setDraftProfile] = useState({
    guardianName: profile.guardianName,
    elderlyName: profile.elderlyName,
    age: profile.age,
    disabilities: profile.disabilities
  });
  const [contactDraft, setContactDraft] = useState({ name: "", phone: "", relationship: "" });
  const [showAddContactForm, setShowAddContactForm] = useState(false);
  const [editingContactId, setEditingContactId] = useState(null);
  const [editingContactDraft, setEditingContactDraft] = useState({ name: "", phone: "", relationship: "" });

  const canAddMoreContact = profile.emergencyContacts.length < 3;

  const handleProfileSave = () => {
    onSaveProfile({ ...profile, ...draftProfile });
    setEditingProfile(false);
  };

  const handleAddContact = () => {
    if (!contactDraft.name || !contactDraft.phone) {
      return;
    }
    onSaveProfile({
      ...profile,
      emergencyContacts: [
        ...profile.emergencyContacts,
        { id: `c${Date.now()}`, name: contactDraft.name, phone: contactDraft.phone, relationship: contactDraft.relationship || "Contact" }
      ]
    });
    setContactDraft({ name: "", phone: "", relationship: "" });
    setShowAddContactForm(false);
  };

  const handleDeleteContact = (id) => {
    onSaveProfile({ ...profile, emergencyContacts: profile.emergencyContacts.filter((contact) => contact.id !== id) });
  };

  const startEditContact = (contact) => {
    setEditingContactId(contact.id);
    setEditingContactDraft({ name: contact.name, phone: contact.phone, relationship: contact.relationship });
  };

  const saveEditContact = () => {
    onSaveProfile({
      ...profile,
      emergencyContacts: profile.emergencyContacts.map((contact) =>
        contact.id === editingContactId ? { ...contact, ...editingContactDraft } : contact
      )
    });
    setEditingContactId(null);
    setEditingContactDraft({ name: "", phone: "", relationship: "" });
  };

  return (
    <section className="screen settings-screen">
      <header className="screen-header">
        <h2>Settings</h2>
      </header>
      <article className="card">
        <div className="row-between">
          <strong>Elderly Profile</strong>
          {!isEditingProfile ? (
            <button className="icon-btn edit-icon" title="Edit elderly profile" aria-label="Edit elderly profile" onClick={() => setEditingProfile(true)}>✏️</button>
          ) : (
            <button className="text-btn" onClick={handleProfileSave}>Save</button>
          )}
        </div>
        {isEditingProfile ? (
          <div className="form-grid compact">
            <input value={draftProfile.guardianName} onChange={(event) => setDraftProfile((prev) => ({ ...prev, guardianName: event.target.value }))} placeholder="Guardian Name" />
            <input value={draftProfile.elderlyName} onChange={(event) => setDraftProfile((prev) => ({ ...prev, elderlyName: event.target.value }))} placeholder="Elderly Person Name" />
            <input value={draftProfile.age} onChange={(event) => setDraftProfile((prev) => ({ ...prev, age: event.target.value }))} placeholder="Age" />
            <input value={draftProfile.disabilities} onChange={(event) => setDraftProfile((prev) => ({ ...prev, disabilities: event.target.value }))} placeholder="Disabilities" />
          </div>
        ) : (
          <>
            <span><strong>Guardian:</strong> {profile.guardianName}</span>
            <span><strong>Elderly:</strong> {profile.elderlyName} (Age {profile.age})</span>
            <span>{profile.disabilities}</span>
          </>
        )}
      </article>

      <article className="card">
        <div className="row-between">
          <strong>Emergency Contacts</strong>
          {canAddMoreContact ? (
            <button className="text-btn" onClick={() => setShowAddContactForm((prev) => !prev)}>
              {showAddContactForm ? "Cancel" : "+ Add"}
            </button>
          ) : (
            <span className="muted">Max 3 contacts</span>
          )}
        </div>
        {profile.emergencyContacts.map((contact) => (
          <div key={contact.id} className="contact-row">
            {editingContactId === contact.id ? (
              <div className="form-grid compact contact-edit-form">
                <input value={editingContactDraft.name} onChange={(event) => setEditingContactDraft((prev) => ({ ...prev, name: event.target.value }))} />
                <input value={editingContactDraft.phone} onChange={(event) => setEditingContactDraft((prev) => ({ ...prev, phone: event.target.value }))} />
                <input value={editingContactDraft.relationship} onChange={(event) => setEditingContactDraft((prev) => ({ ...prev, relationship: event.target.value }))} />
              </div>
            ) : (
              <div>
                <strong>{contact.name}</strong>
                <span>{contact.relationship} - {contact.phone}</span>
              </div>
            )}
            <div className="contact-actions">
              {editingContactId === contact.id ? (
                <button className="text-btn" onClick={saveEditContact}>Save</button>
              ) : (
                <button className="icon-btn edit-icon" title="Edit" aria-label="Edit contact" onClick={() => startEditContact(contact)}>✏️</button>
              )}
              <button className="icon-btn delete-icon" title="Delete" aria-label="Delete contact" onClick={() => handleDeleteContact(contact.id)}>🗑️</button>
            </div>
          </div>
        ))}
        {canAddMoreContact && showAddContactForm ? (
          <div className="form-grid compact">
            <input placeholder="New contact name" value={contactDraft.name} onChange={(event) => setContactDraft((prev) => ({ ...prev, name: event.target.value }))} />
            <input placeholder="New contact phone" value={contactDraft.phone} onChange={(event) => setContactDraft((prev) => ({ ...prev, phone: event.target.value }))} />
            <input placeholder="Relationship (optional)" value={contactDraft.relationship} onChange={(event) => setContactDraft((prev) => ({ ...prev, relationship: event.target.value }))} />
            <button className="btn btn-primary" onClick={handleAddContact}>Add Contact</button>
          </div>
        ) : null}
      </article>

      <article className="card">
        <strong>Notifications</strong>
        {Object.entries(notifications).map(([key, value]) => (
          <div key={key} className="row-between">
            <span>{labelize(key)}</span>
            <button className={`toggle ${value ? "on" : ""}`} onClick={() => onToggleNotification(key)} aria-label={`Toggle ${labelize(key)}`} />
          </div>
        ))}
      </article>
      <button className="btn btn-danger full" onClick={onSignOut}>Sign Out</button>
    </section>
  );
}

function BottomNav({ tab, onChange }) {
  const items = [
    { id: "home", label: "Home", icon: "🏠" },
    { id: "alerts", label: "Alerts", icon: "🔔" },
    { id: "settings", label: "Settings", icon: "⚙️" }
  ];

  return (
    <nav className="bottom-nav">
      {items.map((item) => (
        <button
          key={item.id}
          className={tab === item.id ? "active" : ""}
          onClick={() => onChange(item.id)}
        >
          <span className="bottom-nav-icon" aria-hidden="true">{item.icon}</span>
          <span>{item.label}</span>
        </button>
      ))}
    </nav>
  );
}

function labelize(text) {
  return text
    .replace(/([A-Z])/g, " $1")
    .replace(/^./, (char) => char.toUpperCase());
}

function formatAlertDate(dateString) {
  const date = new Date(dateString);
  const weekday = date.toLocaleDateString("en-US", { weekday: "long" });
  const monthDay = date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
  const time = date.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true });
  return `${weekday}, ${monthDay} at ${time}`;
}

function getGreetingMessage() {
  const hour = new Date().getHours();
  if (hour < 12) {
    return "Good Morning";
  }
  if (hour < 17) {
    return "Good Afternoon";
  }
  return "Good Evening";
}

function mapSignUpToProfile(form) {
  return {
    guardianName: form.guardianName,
    elderlyName: form.elderlyName,
    age: form.age,
    disabilities: form.disabilities,
    emergencyContacts: [
      {
        id: "c1",
        name: form.emergencyContact1Name,
        phone: form.emergencyContact1Phone,
        relationship: "Emergency Contact 1"
      },
      {
        id: "c2",
        name: form.emergencyContact2Name,
        phone: form.emergencyContact2Phone,
        relationship: "Emergency Contact 2"
      }
    ]
  };
}

function formatOnlyTime(dateString) {
  const date = new Date(dateString);
  return date.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true });
}

export default App;
