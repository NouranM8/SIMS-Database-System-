"""
app.py — SIMS Tkinter UI
Minimalist, page-themed design. Single file, all screens.
Run:  python app.py
"""

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
from datetime import date
import sys

# ── try importing logic; guide user if missing ──────────────────
try:
    import logic
except ImportError:
    print("logic.py not found. Place logic.py in the same folder.")
    sys.exit(1)

# ════════════════════════════════════════════════════════════════
#  THEME
# ════════════════════════════════════════════════════════════════
C = {
    "page":      "#F5F2EC",
    "surface":   "#FFFFFF",
    "ink":       "#1C1C1C",
    "ink2":      "#6B6B6B",
    "ink3":      "#ABABAB",
    "accent":    "#2D5BE3",
    "accent2":   "#E8EFFE",
    "border":    "#E0DDD6",
    "danger":    "#C0392B",
    "success":   "#27AE60",
    "warn":      "#E67E22",
    "sidebar":   "#1C1C1C",
    "sidebar2":  "#2E2E2E",
    "stext":     "#F5F2EC",
    "stext2":    "#9A9A9A",
}
FONT_H1   = ("Georgia", 22, "bold")
FONT_H2   = ("Georgia", 16, "bold")
FONT_H3   = ("Georgia", 13, "bold")
FONT_BODY = ("Georgia", 11)
FONT_SM   = ("Georgia", 10)
FONT_MONO = ("Courier", 10)
FONT_LABEL= ("Georgia", 10)
FONT_BTN  = ("Georgia", 11, "bold")
FONT_NAV  = ("Georgia", 10)   # slightly smaller so all items fit

PAD = 24

# ════════════════════════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════════════════════════

def clear(frame):
    for w in frame.winfo_children():
        w.destroy()

def page_title(parent, text, subtitle=""):
    tk.Label(parent, text=text, font=FONT_H1,
             bg=C["page"], fg=C["ink"]).pack(anchor="w")
    if subtitle:
        tk.Label(parent, text=subtitle, font=FONT_BODY,
                 bg=C["page"], fg=C["ink2"]).pack(anchor="w", pady=(2,0))
    tk.Frame(parent, height=1, bg=C["border"]).pack(fill="x", pady=(12,18))

def card(parent, **kw):
    return tk.Frame(parent, bg=C["surface"], relief="flat", bd=0,
                    highlightthickness=1, highlightbackground=C["border"], **kw)

def btn(parent, text, cmd, kind="primary", **kw):
    colors = {
        "primary": (C["accent"],  C["surface"], C["accent"]),
        "ghost":   (C["surface"], C["ink"],     C["border"]),
        "danger":  (C["danger"],  C["surface"], C["danger"]),
    }
    bg, fg, bd_col = colors.get(kind, colors["primary"])
    b = tk.Button(parent, text=text, command=cmd, font=FONT_BTN,
                  bg=bg, fg=fg, relief="flat", cursor="hand2",
                  activebackground=C["accent2"], activeforeground=C["ink"],
                  padx=16, pady=6, **kw)
    b.configure(highlightbackground=bd_col, highlightthickness=1)
    return b

def lbl_val(parent, label, value, row, col=0):
    tk.Label(parent, text=label, font=FONT_LABEL,
             bg=C["surface"], fg=C["ink2"]).grid(
        row=row, column=col*2, sticky="w", padx=(16,4), pady=4)
    tk.Label(parent, text=str(value) if value else "—", font=FONT_BODY,
             bg=C["surface"], fg=C["ink"]).grid(
        row=row, column=col*2+1, sticky="w", padx=(0,24), pady=4)

def separator(parent):
    tk.Frame(parent, height=1, bg=C["border"]).pack(fill="x", pady=8)

def stat_box(parent, label, value, color=None):
    f = card(parent, padx=20, pady=16)
    tk.Label(f, text=str(value), font=("Georgia", 26, "bold"),
             bg=C["surface"], fg=color or C["accent"]).pack(anchor="w")
    tk.Label(f, text=label, font=FONT_SM,
             bg=C["surface"], fg=C["ink2"]).pack(anchor="w")
    return f

def scrollable(parent):
    canvas = tk.Canvas(parent, bg=C["page"], highlightthickness=0)
    sb = ttk.Scrollbar(parent, orient="vertical", command=canvas.yview)
    frame = tk.Frame(canvas, bg=C["page"])
    frame.bind("<Configure>",
               lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.create_window((0,0), window=frame, anchor="nw")
    canvas.configure(yscrollcommand=sb.set)
    canvas.pack(side="left", fill="both", expand=True)
    sb.pack(side="right", fill="y")
    canvas.bind_all("<MouseWheel>",
        lambda e: canvas.yview_scroll(int(-1*(e.delta/120)), "units"))
    return frame

def make_tree(parent, columns, heights=12):
    style = ttk.Style()
    style.theme_use("clam")
    style.configure("SIMS.Treeview",
        background=C["surface"], foreground=C["ink"],
        rowheight=30, fieldbackground=C["surface"],
        font=FONT_BODY, borderwidth=0)
    style.configure("SIMS.Treeview.Heading",
        background=C["page"], foreground=C["ink2"],
        font=FONT_LABEL, relief="flat", borderwidth=0)
    style.map("SIMS.Treeview",
        background=[("selected", C["accent2"])],
        foreground=[("selected", C["ink"])])
    tree = ttk.Treeview(parent, columns=columns, show="headings",
                        style="SIMS.Treeview", height=heights)
    for col in columns:
        tree.heading(col, text=col)
        tree.column(col, width=120, anchor="w")
    sb = ttk.Scrollbar(parent, orient="vertical", command=tree.yview)
    tree.configure(yscrollcommand=sb.set)
    tree.pack(side="left", fill="both", expand=True)
    sb.pack(side="right", fill="y")
    return tree

def entry_field(parent, label, row, show=None, default=""):
    tk.Label(parent, text=label, font=FONT_LABEL,
             bg=C["page"], fg=C["ink2"]).grid(row=row, column=0, sticky="w", pady=(8,2))
    var = tk.StringVar(value=default)
    e = tk.Entry(parent, textvariable=var, font=FONT_BODY,
                 bg=C["surface"], fg=C["ink"], relief="flat", bd=0,
                 highlightthickness=1, highlightbackground=C["border"],
                 highlightcolor=C["accent"], insertbackground=C["ink"], show=show or "")
    e.grid(row=row+1, column=0, sticky="ew", ipady=6, pady=(0,4))
    return var

def combo_field(parent, label, row, values, default=""):
    tk.Label(parent, text=label, font=FONT_LABEL,
             bg=C["page"], fg=C["ink2"]).grid(row=row, column=0, sticky="w", pady=(8,2))
    var = tk.StringVar(value=default)
    style = ttk.Style()
    style.configure("SIMS.TCombobox", fieldbackground=C["surface"],
                    background=C["surface"], foreground=C["ink"])
    cb = ttk.Combobox(parent, textvariable=var, values=values,
                      font=FONT_BODY, style="SIMS.TCombobox", state="readonly")
    cb.grid(row=row+1, column=0, sticky="ew", ipady=4, pady=(0,4))
    return var

# ════════════════════════════════════════════════════════════════
#  MODAL DIALOG
# ════════════════════════════════════════════════════════════════

class Modal(tk.Toplevel):
    def __init__(self, parent, title, width=460, height=520):
        super().__init__(parent)
        self.title(title)
        self.configure(bg=C["page"])
        self.geometry(f"{width}x{height}")
        self.resizable(False, False)
        self.grab_set()
        tk.Label(self, text=title, font=FONT_H2,
                 bg=C["page"], fg=C["ink"]).pack(anchor="w", padx=PAD, pady=(PAD,4))
        tk.Frame(self, height=1, bg=C["border"]).pack(fill="x", padx=PAD)
        self.body = tk.Frame(self, bg=C["page"])
        self.body.pack(fill="both", expand=True, padx=PAD, pady=PAD)
        self.body.columnconfigure(0, weight=1)


# ════════════════════════════════════════════════════════════════
#  LOGIN SCREEN
# ════════════════════════════════════════════════════════════════

class LoginScreen(tk.Frame):
    def __init__(self, master, on_login):
        super().__init__(master, bg=C["page"])
        self.on_login = on_login
        self._build()

    def _build(self):
        tk.Frame(self, bg=C["accent"], width=6).pack(side="left", fill="y")
        center = tk.Frame(self, bg=C["page"])
        center.pack(expand=True)
        tk.Label(center, text="SIMS", font=("Georgia", 48, "bold"),
                 bg=C["page"], fg=C["ink"]).pack(pady=(0,2))
        tk.Label(center, text="School Information Management System",
                 font=FONT_BODY, bg=C["page"], fg=C["ink2"]).pack()
        tk.Frame(center, height=1, bg=C["border"], width=320).pack(pady=28)
        f = card(center, padx=36, pady=36)
        f.pack(ipadx=10)
        tk.Label(f, text="Sign in", font=FONT_H2,
                 bg=C["surface"], fg=C["ink"]).pack(anchor="w", pady=(0,20))
        tk.Label(f, text="Username", font=FONT_LABEL,
                 bg=C["surface"], fg=C["ink2"]).pack(anchor="w")
        self.uvar = tk.StringVar()
        u_entry = tk.Entry(f, textvariable=self.uvar, font=FONT_BODY,
                           bg=C["page"], fg=C["ink"], relief="flat",
                           highlightthickness=1, highlightbackground=C["border"],
                           highlightcolor=C["accent"], width=28, insertbackground=C["ink"])
        u_entry.pack(fill="x", ipady=8, pady=(4,14))
        u_entry.focus()
        tk.Label(f, text="Password", font=FONT_LABEL,
                 bg=C["surface"], fg=C["ink2"]).pack(anchor="w")
        self.pvar = tk.StringVar()
        p_entry = tk.Entry(f, textvariable=self.pvar, show="•",
                           font=FONT_BODY, bg=C["page"], fg=C["ink"], relief="flat",
                           highlightthickness=1, highlightbackground=C["border"],
                           highlightcolor=C["accent"], width=28, insertbackground=C["ink"])
        p_entry.pack(fill="x", ipady=8, pady=(4,24))
        p_entry.bind("<Return>", lambda e: self._login())
        self.err = tk.Label(f, text="", font=FONT_SM, bg=C["surface"], fg=C["danger"])
        self.err.pack(anchor="w", pady=(0,8))
        btn(f, "Sign in →", self._login).pack(fill="x", ipady=4)

    def _login(self):
        conn = logic.get_connection()
        user = logic.login(conn, self.uvar.get().strip(), self.pvar.get().strip())
        conn.close()
        if user:
            self.on_login(user)
        else:
            self.err.config(text="Invalid username or password.")


# ════════════════════════════════════════════════════════════════
#  SIDEBAR  ── FIX: sign-out pinned at bottom, nav scrolls if needed
# ════════════════════════════════════════════════════════════════

class Sidebar(tk.Frame):
    def __init__(self, master, items, on_select, user_name, role, on_signout):
        super().__init__(master, bg=C["sidebar"], width=220)
        self.pack_propagate(False)
        self.items     = items
        self.on_select = on_select
        self.btns      = {}
        self.active    = None
        self._build(user_name, role, on_signout)

    def _build(self, user_name, role, on_signout):
        # ── Fixed header ─────────────────────────────────
        hdr = tk.Frame(self, bg=C["sidebar"])
        hdr.pack(fill="x", side="top")
        tk.Label(hdr, text="SIMS", font=("Georgia", 20, "bold"),
                 bg=C["sidebar"], fg=C["stext"]).pack(anchor="w", padx=16, pady=(16,2))
        tk.Label(hdr, text="Management System", font=("Georgia", 9),
                 bg=C["sidebar"], fg=C["stext2"]).pack(anchor="w", padx=16)
        tk.Frame(hdr, height=1, bg=C["sidebar2"]).pack(fill="x", pady=10)

        # ── Fixed footer: sign-out + user info ──────────
        ftr = tk.Frame(self, bg=C["sidebar"])
        ftr.pack(fill="x", side="bottom")
        tk.Label(ftr, text=role.upper(), font=("Georgia", 8, "bold"),
                 bg=C["sidebar"], fg=C["accent"]).pack(anchor="w", padx=16, pady=(10,1))
        tk.Label(ftr, text=user_name, font=("Georgia", 10),
                 bg=C["sidebar"], fg=C["stext"]).pack(anchor="w", padx=16, pady=(0,6))
        tk.Frame(ftr, height=1, bg=C["sidebar2"]).pack(fill="x")
        tk.Button(ftr, text="  ⏻  Sign out",
                  font=("Georgia", 10, "bold"),
                  bg=C["sidebar"], fg="#FF6B6B",
                  relief="flat", anchor="w", cursor="hand2",
                  activebackground="#3A1A1A", activeforeground="#FF6B6B",
                  command=on_signout).pack(fill="x", ipady=12)

        # ── Scrollable nav canvas ────────────────────────
        nav_wrap = tk.Frame(self, bg=C["sidebar"])
        nav_wrap.pack(fill="both", expand=True, side="top")
        nav_canvas = tk.Canvas(nav_wrap, bg=C["sidebar"], highlightthickness=0, bd=0)
        nav_sb = ttk.Scrollbar(nav_wrap, orient="vertical", command=nav_canvas.yview)
        nav_canvas.configure(yscrollcommand=nav_sb.set)
        nav_canvas.pack(side="left", fill="both", expand=True)
        nav_sb.pack(side="right", fill="y")
        nav_frame = tk.Frame(nav_canvas, bg=C["sidebar"])
        nav_canvas.create_window((0,0), window=nav_frame, anchor="nw", width=220)

        def _resize(e):
            nav_canvas.configure(scrollregion=nav_canvas.bbox("all"))
        nav_frame.bind("<Configure>", _resize)

        def _wheel(e):
            # Windows/Mac: e.delta; Linux: e.num
            if e.delta:
                nav_canvas.yview_scroll(int(-1*(e.delta/120)), "units")
            elif e.num == 4:
                nav_canvas.yview_scroll(-1, "units")
            elif e.num == 5:
                nav_canvas.yview_scroll(1, "units")
        nav_canvas.bind("<MouseWheel>", _wheel)
        nav_canvas.bind("<Button-4>", _wheel)
        nav_canvas.bind("<Button-5>", _wheel)
        nav_frame.bind("<MouseWheel>", _wheel)
        nav_frame.bind("<Button-4>", _wheel)
        nav_frame.bind("<Button-5>", _wheel)

        for label, key in self.items:
            b = tk.Button(nav_frame, text=f"  {label}",
                          font=FONT_NAV, bg=C["sidebar"], fg=C["stext"],
                          relief="flat", anchor="w", cursor="hand2",
                          activebackground=C["sidebar2"], activeforeground=C["stext"],
                          command=lambda k=key: self._select(k))
            b.pack(fill="x", ipady=8)
            b.bind("<MouseWheel>", _wheel)
            b.bind("<Button-4>",   _wheel)
            b.bind("<Button-5>",   _wheel)
            self.btns[key] = b

    def _select(self, key):
        if self.active:
            self.btns[self.active].config(bg=C["sidebar"], fg=C["stext"])
        self.btns[key].config(bg=C["accent"], fg=C["surface"])
        self.active = key
        self.on_select(key)

    def select_first(self):
        if self.items:
            self._select(self.items[0][1])


# ════════════════════════════════════════════════════════════════
#  CONTENT AREA BASE
# ════════════════════════════════════════════════════════════════

class ContentArea(tk.Frame):
    def __init__(self, master, user):
        super().__init__(master, bg=C["page"])
        self.user = user
        self.conn = logic.get_connection()

    def show(self, key):
        clear(self)
        inner = tk.Frame(self, bg=C["page"], padx=PAD*2, pady=PAD*2)
        inner.pack(fill="both", expand=True)
        handler = getattr(self, f"page_{key}", None)
        if handler:
            handler(inner)

    def destroy(self):
        try:
            self.conn.close()
        except Exception:
            pass
        super().destroy()


# ════════════════════════════════════════════════════════════════
#  ADMIN CONTENT
# ════════════════════════════════════════════════════════════════

class AdminContent(ContentArea):

    def page_dashboard(self, p):
        page_title(p, "Dashboard", "School overview at a glance")
        stats = logic.get_dashboard_stats(self.conn)
        sem = stats.get("active_semester")
        if sem:
            banner = tk.Frame(p, bg=C["accent2"],
                              highlightthickness=1, highlightbackground=C["accent"])
            banner.pack(fill="x", pady=(0,14))
            tk.Label(banner,
                     text=f"★  Active Semester: {sem['name']} {sem['year_name']}",
                     font=FONT_BODY, bg=C["accent2"], fg=C["accent"],
                     padx=16, pady=8).pack(side="left")
            pending = stats.get("finals_pending", 0)
            p_col = C["danger"] if pending > 0 else C["success"]
            tk.Label(banner, text=f"Finals pending: {pending}",
                     font=FONT_BODY, bg=C["accent2"], fg=p_col,
                     padx=16, pady=8).pack(side="right")
        row = tk.Frame(p, bg=C["page"])
        row.pack(fill="x", pady=(0,16))
        for label, val, col in [
            ("Active Students", stats["total_students"], C["accent"]),
            ("Teachers",        stats["total_teachers"], C["ink"]),
            ("Classes",         stats["total_classes"],  C["ink"]),
            ("Graduated",       stats["graduated"],      C["success"]),
            ("Withdrawn",       stats["withdrawn"],      C["warn"]),
        ]:
            stat_box(row, label, val, col).pack(side="left", padx=(0,10))
        separator(p)
        cols = tk.Frame(p, bg=C["page"])
        cols.pack(fill="both", expand=True)

        # ── Left: Recent grade entries (GradeDetail activity) ────────
        left = tk.Frame(cols, bg=C["page"])
        left.pack(side="left", fill="both", expand=True, padx=(0,16))
        tk.Label(left, text="Recent grade entries",
                 font=FONT_H3, bg=C["page"], fg=C["ink"]).pack(anchor="w", pady=(0,8))
        f = card(left); f.pack(fill="both", expand=True)
        recent = logic.get_recent_grade_activity(self.conn)
        if recent:
            tree = make_tree(f, ("Student","Class","Subject","Q1","Q2","Mid","Final"), heights=10)
            tree.column("Student",width=150); tree.column("Class",width=55)
            tree.column("Subject",width=120); tree.column("Q1",width=40)
            tree.column("Q2",width=40); tree.column("Mid",width=45); tree.column("Final",width=55)
            for r in recent:
                tree.insert("","end", values=(
                    f"{r['f_name']} {r['l_name']}",
                    f"{r['grade']}-{r['section']}",
                    r["subject"],
                    r.get("quiz1","—") or "—", r.get("quiz2","—") or "—",
                    r.get("midterm","—") or "—",
                    r.get("final_exam","Pending") or "Pending"))
        else:
            tk.Label(f, text="No grade data entered yet for this semester.",
                     font=FONT_BODY, bg=C["surface"], fg=C["ink2"],
                     padx=16, pady=16).pack(anchor="w")

        # ── Right: Today attendance + class summary ───────────────────
        right = tk.Frame(cols, bg=C["page"], width=210)
        right.pack(side="right", fill="y"); right.pack_propagate(False)
        tk.Label(right, text="Today's attendance",
                 font=FONT_H3, bg=C["page"], fg=C["ink"]).pack(anchor="w", pady=(0,8))
        f2 = card(right, padx=16, pady=14); f2.pack(fill="x")
        totals = {r["status"]: r["n"] for r in stats["attendance_today"]}
        for status, col in [("Present",C["success"]),("Absent",C["danger"]),
                            ("Late",C["warn"]),("Excused",C["ink2"])]:
            rw2 = tk.Frame(f2, bg=C["surface"]); rw2.pack(fill="x", pady=4)
            tk.Label(rw2, text=status, font=FONT_BODY, bg=C["surface"], fg=C["ink"]).pack(side="left")
            tk.Label(rw2, text=str(totals.get(status,0)), font=FONT_H3,
                     bg=C["surface"], fg=col).pack(side="right")

    def page_students(self, p):
        page_title(p, "Students", "All enrolled students")
        bar = tk.Frame(p, bg=C["page"]); bar.pack(fill="x", pady=(0,12))
        self._svar = tk.StringVar()
        tk.Entry(bar, textvariable=self._svar, font=FONT_BODY,
                 bg=C["surface"], fg=C["ink"], relief="flat",
                 highlightthickness=1, highlightbackground=C["border"],
                 highlightcolor=C["accent"], width=30, insertbackground=C["ink"]
                 ).pack(side="left", ipady=6, padx=(0,8))
        btn(bar, "Search", self._search_students, "ghost").pack(side="left", padx=(0,8))
        btn(bar, "+ Add Student", self._add_student_modal).pack(side="right")
        btn(bar, "⚠ Withdraw Selected", self._withdraw_selected, "ghost").pack(side="right", padx=(0,8))
        f = card(p); f.pack(fill="both", expand=True)
        cols = ("ID","Name","Gender","Class","Guardian","Phone")
        self._stree = make_tree(f, cols, heights=18)
        self._stree.column("ID",width=50); self._stree.column("Name",width=180)
        self._stree.column("Gender",width=70); self._stree.column("Class",width=70)
        self._stree.column("Guardian",width=160); self._stree.column("Phone",width=130)
        self._stree.bind("<Double-1>", self._student_detail)
        self._load_students()

    def _load_students(self, rows=None):
        self._stree.delete(*self._stree.get_children())
        data = rows or logic.get_all_students(self.conn)
        for r in data:
            self._stree.insert("","end", iid=str(r["student_id"]), values=(
                r["student_id"], f"{r['f_name']} {r['l_name']}", r["gender"],
                f"{r['grade']}-{r['section']}",
                f"{r['guardian_fname']} {r['guardian_lname']}", r["phone_no"]))

    def _search_students(self):
        kw = self._svar.get().strip()
        if not kw: self._load_students(); return
        rows = logic.search_students(self.conn, kw)
        self._stree.delete(*self._stree.get_children())
        for r in rows:
            self._stree.insert("","end", iid=str(r["student_id"]), values=(
                r["student_id"], f"{r['f_name']} {r['l_name']}", r["gender"],
                f"{r['grade']}-{r['section']}", "—","—"))

    def _student_detail(self, event):
        sel = self._stree.selection()
        if not sel: return
        sid = int(sel[0])
        s = logic.get_student_by_id(self.conn, sid)
        if not s: return
        m = Modal(self, f"Student #{sid}", width=520, height=560); f = m.body
        tk.Label(f, text=f"{s['f_name']} {s['l_name']}", font=FONT_H2,
                 bg=C["page"], fg=C["ink"]).grid(row=0,column=0,columnspan=2,sticky="w",pady=(0,12))
        info = card(f); info.grid(row=1,column=0,columnspan=2,sticky="ew",pady=(0,12))
        for i,(lbl,val) in enumerate([
            ("Student ID",s["student_id"]),("Gender",s["gender"]),
            ("Date of Birth",s["birth_date"]),("Address",s["address"]),
            ("Class",f"{s['grade']}-{s['section']}")]):
            lbl_val(info,lbl,val,i)
        tk.Label(f,text="Guardian",font=FONT_H3,bg=C["page"],fg=C["ink"]).grid(
            row=2,column=0,sticky="w",pady=(8,4))
        g = card(f); g.grid(row=3,column=0,columnspan=2,sticky="ew")
        for i,(lbl,val) in enumerate([
            ("Name",f"{s['g_fname']} {s['g_lname']}"),("Phone",s["g_phone"]),("Gender",s["g_gender"])]):
            lbl_val(g,lbl,val,i)
        brow = tk.Frame(f,bg=C["page"]); brow.grid(row=4,column=0,columnspan=2,sticky="ew",pady=16)
        btn(brow,"Edit",lambda: self._edit_student(sid,m)).pack(side="left",padx=(0,8))
        btn(brow,"Withdraw",lambda: self._withdraw_student(sid,m),"ghost").pack(side="left",padx=(0,8))
        btn(brow,"Delete",lambda: self._delete_student(sid,m),"danger").pack(side="left")

    def _add_student_modal(self):
        m = Modal(self,"Add Student",height=600); f = m.body
        classes = logic.get_all_classes(self.conn)
        class_opts = [f"{c['grade']}-{c['section']} (ID:{c['class_id']})" for c in classes]
        class_ids  = {f"{c['grade']}-{c['section']} (ID:{c['class_id']})":c["class_id"] for c in classes}
        fname=entry_field(f,"First name",0); lname=entry_field(f,"Last name",2)
        gender=combo_field(f,"Gender",4,["Male","Female"])
        dob=entry_field(f,"Date of birth (YYYY-MM-DD)",6); addr=entry_field(f,"Address",8)
        cls=combo_field(f,"Class",10,class_opts)
        gfname=entry_field(f,"Guardian first name",12); glname=entry_field(f,"Guardian last name",14)
        gphone=entry_field(f,"Guardian phone",16); ggend=combo_field(f,"Guardian gender",18,["Male","Female"])
        def save():
            try:
                gid = logic.add_guardian(self.conn,gfname.get(),glname.get(),gphone.get(),ggend.get())
                sid = logic.add_student(self.conn,fname.get(),lname.get(),gender.get(),
                    dob.get(),addr.get(),gid,class_ids[cls.get()])
                uname = f"{fname.get().lower()}.{lname.get().lower()}"
                logic.create_user(self.conn,uname,"student123","student",sid,None)
                messagebox.showinfo("Done",f"Student added. Login: {uname} / student123")
                m.destroy(); self._load_students()
            except Exception as ex: messagebox.showerror("Error",str(ex))
        btn(f,"Save Student",save).grid(row=20,column=0,sticky="ew",pady=16)

    def _edit_student(self,sid,parent_modal):
        s=logic.get_student_by_id(self.conn,sid)
        m=Modal(self,"Edit Student",height=480); f=m.body
        classes=logic.get_all_classes(self.conn)
        class_opts=[f"{c['grade']}-{c['section']} (ID:{c['class_id']})" for c in classes]
        class_ids={f"{c['grade']}-{c['section']} (ID:{c['class_id']})":c["class_id"] for c in classes}
        current_cls=next((f"{c['grade']}-{c['section']} (ID:{c['class_id']})"
            for c in classes if c["class_id"]==s["class_id"]),"")
        fname=entry_field(f,"First name",0,default=s["f_name"])
        lname=entry_field(f,"Last name",2,default=s["l_name"])
        gender=combo_field(f,"Gender",4,["Male","Female"],s["gender"])
        dob=entry_field(f,"Date of birth",6,default=str(s["birth_date"]))
        addr=entry_field(f,"Address",8,default=s["address"])
        cls=combo_field(f,"Class",10,class_opts,current_cls)
        def save():
            try:
                logic.update_student(self.conn,sid,fname.get(),lname.get(),gender.get(),
                    dob.get(),addr.get(),class_ids[cls.get()])
                messagebox.showinfo("Done","Student updated.")
                m.destroy(); parent_modal.destroy(); self._load_students()
            except Exception as ex: messagebox.showerror("Error",str(ex))
        btn(f,"Save Changes",save).grid(row=12,column=0,sticky="ew",pady=16)

    def _withdraw_student(self,sid,modal):
        s=logic.get_student_by_id(self.conn,sid)
        name=f"{s['f_name']} {s['l_name']}"
        if messagebox.askyesno("Withdraw Student",
            f"Withdraw {name}?\n\nThey will be moved to Past Students and can no longer log in."):
            logic.withdraw_student(self.conn,sid)
            modal.destroy(); self._load_students()
            messagebox.showinfo("Done",f"{name} has been withdrawn.")

    def _withdraw_selected(self):
        sel=self._stree.selection()
        if not sel:
            messagebox.showwarning("No selection","Please select a student from the list first."); return
        sid=int(sel[0])
        s=logic.get_student_by_id(self.conn,sid)
        if not s: return
        name=f"{s['f_name']} {s['l_name']}"
        if messagebox.askyesno("Withdraw Student",
            f"Withdraw {name}?\n\nThey will be moved to Past Students and can no longer log in."):
            logic.withdraw_student(self.conn,sid)
            self._load_students()
            messagebox.showinfo("Done",f"{name} has been withdrawn.")

    def _delete_student(self,sid,modal):
        if messagebox.askyesno("Delete","Delete this student permanently?"):
            logic.delete_student(self.conn,sid); modal.destroy(); self._load_students()

    def page_teachers(self,p):
        page_title(p,"Teachers","Teaching staff directory")
        bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,12))
        btn(bar,"+ Add Teacher",self._add_teacher_modal).pack(side="right")
        f=card(p); f.pack(fill="both",expand=True)
        cols=("ID","Name","Email","Phone","Gender")
        self._ttree=make_tree(f,cols,heights=18)
        self._ttree.column("ID",width=50); self._ttree.column("Name",width=200)
        self._ttree.column("Email",width=220); self._ttree.column("Phone",width=130)
        self._ttree.column("Gender",width=80)
        self._ttree.bind("<Double-1>",self._teacher_detail)
        self._load_teachers()

    def _load_teachers(self):
        self._ttree.delete(*self._ttree.get_children())
        for r in logic.get_all_teachers(self.conn):
            self._ttree.insert("","end",iid=str(r["teacher_id"]),values=(
                r["teacher_id"],f"{r['f_name']} {r['l_name']}",
                r["email"],r["phone_no"],r["gender"]))

    def _teacher_detail(self,event):
        sel=self._ttree.selection()
        if not sel: return
        tid=int(sel[0]); t=logic.get_teacher_by_id(self.conn,tid)
        m=Modal(self,f"Teacher #{tid}",height=420); f=m.body
        info=card(f); info.pack(fill="x",pady=(0,12))
        for i,(lbl,val) in enumerate([
            ("Name",f"{t['f_name']} {t['l_name']}"),("Email",t["email"]),
            ("Phone",t["phone_no"]),("Gender",t["gender"]),("Birth Date",t["birth_date"])]):
            lbl_val(info,lbl,val,i)
        brow=tk.Frame(f,bg=C["page"]); brow.pack(fill="x",pady=8)
        btn(brow,"Delete",lambda: self._delete_teacher(tid,m),"danger").pack(side="left")

    def _add_teacher_modal(self):
        m=Modal(self,"Add Teacher",height=560); f=m.body
        fname=entry_field(f,"First name",0); lname=entry_field(f,"Last name",2)
        email=entry_field(f,"Email",4); phone=entry_field(f,"Phone",6)
        gender=combo_field(f,"Gender",8,["Male","Female"])
        dob=entry_field(f,"Date of birth (YYYY-MM-DD)",10)
        def save():
            try:
                tid2=logic.add_teacher(self.conn,fname.get(),lname.get(),
                    email.get(),phone.get(),gender.get(),dob.get())
                uname=(fname.get().lower().strip()+"."+lname.get().lower().strip()).replace(" ","")
                logic.create_user(self.conn,uname,"teacher123","teacher",None,tid2)
                messagebox.showinfo("Done","Teacher added.\nLogin: "+uname+" / teacher123")
                m.destroy(); self._load_teachers()
            except Exception as ex: messagebox.showerror("Error",str(ex))
        btn(f,"Save Teacher",save).grid(row=12,column=0,sticky="ew",pady=16)

    def _delete_teacher(self,tid,modal):
        if messagebox.askyesno("Delete","Delete this teacher?"):
            logic.delete_teacher(self.conn,tid); modal.destroy(); self._load_teachers()

    def page_classes(self,p):
        page_title(p,"Classes","Grade levels and sections")
        bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,12))
        btn(bar,"+ Add Class",self._add_class_modal).pack(side="right")
        f=card(p); f.pack(fill="both",expand=True)
        cols=("ID","Grade","Section","Homeroom Teacher","Students")
        self._ctree=make_tree(f,cols,heights=16)
        self._ctree.column("ID",width=50); self._ctree.column("Grade",width=70)
        self._ctree.column("Section",width=70); self._ctree.column("Homeroom Teacher",width=200)
        self._ctree.column("Students",width=80)
        self._load_classes()

    def _load_classes(self):
        self._ctree.delete(*self._ctree.get_children())
        for r in logic.get_all_classes(self.conn):
            self._ctree.insert("","end",values=(
                r["class_id"],r["grade"],r["section"],
                f"{r['f_name']} {r['l_name']}",r["student_count"]))

    def _add_class_modal(self):
        m=Modal(self,"Add Class",height=340); f=m.body
        teachers=logic.get_all_teachers(self.conn)
        t_opts=[f"{t['f_name']} {t['l_name']} (ID:{t['teacher_id']})" for t in teachers]
        t_ids={f"{t['f_name']} {t['l_name']} (ID:{t['teacher_id']})":t["teacher_id"] for t in teachers}
        grade=combo_field(f,"Grade",0,[str(g) for g in range(1,13)])
        section=combo_field(f,"Section",2,["A","B","C","D"])
        teacher=combo_field(f,"Homeroom Teacher",4,t_opts)
        def save():
            try:
                logic.add_class(self.conn,grade.get(),section.get(),t_ids[teacher.get()])
                messagebox.showinfo("Done","Class added."); m.destroy(); self._load_classes()
            except Exception as ex: messagebox.showerror("Error",str(ex))
        btn(f,"Save Class",save).grid(row=6,column=0,sticky="ew",pady=16)

    def page_grades(self,p):
        page_title(p,"Grades","Search a student to view their full grade history")
        bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,12))
        self._gsvar=tk.StringVar()
        tk.Entry(bar,textvariable=self._gsvar,font=FONT_BODY,
                 bg=C["surface"],fg=C["ink"],relief="flat",
                 highlightthickness=1,highlightbackground=C["border"],
                 width=24,insertbackground=C["ink"]).pack(side="left",ipady=6,padx=(0,8))
        btn(bar,"Search Student",self._grade_search,"ghost").pack(side="left")
        self._grade_area=tk.Frame(p,bg=C["page"])
        self._grade_area.pack(fill="both",expand=True)

    def _grade_search(self):
        clear(self._grade_area)
        rows=logic.search_students(self.conn,self._gsvar.get())
        if not rows:
            tk.Label(self._grade_area,text="No students found.",
                     font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(pady=20); return
        for r in rows[:10]:
            row=tk.Frame(self._grade_area,bg=C["surface"],
                         highlightthickness=1,highlightbackground=C["border"])
            row.pack(fill="x",pady=3)
            tk.Label(row,text=f"{r['f_name']} {r['l_name']} — Grade {r['grade']}-{r['section']}",
                     font=FONT_BODY,bg=C["surface"],fg=C["ink"],padx=12).pack(side="left",pady=8)
            sid=r["student_id"]
            btn(row,"View Grades",lambda s=sid: self._show_student_grades(s),"ghost").pack(side="right",padx=8)

    def _show_student_grades(self,sid):
        s=logic.get_student_by_id(self.conn,sid)
        m=Modal(self,f"Grades — {s['f_name']} {s['l_name']}",width=720,height=620); f=m.body
        # ── Fixed footer: GPA + PDF export (packed FIRST so it's always visible) ──
        footer=tk.Frame(f,bg=C["page"]); footer.pack(side="bottom",fill="x",pady=(8,0))
        sems=logic.get_semesters_with_year(self.conn)
        sem_opts_pdf={f"{sm['name']} {sm['year_name']}":sm["semester_id"] for sm in reversed(sems)} if sems else {}
        exp_sem_var=tk.StringVar(value=list(sem_opts_pdf.keys())[0] if sem_opts_pdf else "")
        exp_row=tk.Frame(footer,bg=C["page"]); exp_row.pack(fill="x",pady=(4,0))
        if sem_opts_pdf:
            ttk.Combobox(exp_row,textvariable=exp_sem_var,values=list(sem_opts_pdf.keys()),
                         font=FONT_BODY,state="readonly",width=24).pack(side="left",padx=(0,8))
        def _admin_export():
            if not sem_opts_pdf or not exp_sem_var.get(): return
            from tkinter import filedialog
            rc=logic.get_report_card(self.conn,sid,sem_opts_pdf[exp_sem_var.get()])
            if not rc["grades"]:
                messagebox.showinfo("No data","No grades for that semester."); return
            sname=f"{rc['student']['f_name']}_{rc['student']['l_name']}".replace(" ","_")
            sem_tag=exp_sem_var.get().replace(" ","_")
            path=filedialog.asksaveasfilename(
                defaultextension=".pdf",
                filetypes=[("PDF files","*.pdf")],
                initialfile=f"ReportCard_{sname}_{sem_tag}.pdf",
                title="Save Report Card PDF")
            if not path: return
            try:
                logic.export_report_card_pdf(rc, path)
                messagebox.showinfo("Exported",f"PDF saved to:\n{path}")
            except Exception as ex:
                messagebox.showerror("Export failed",str(ex))
        btn(exp_row,"⬇  Export Report Card PDF",_admin_export,"primary").pack(side="left")
        gpa=logic.get_gpa(self.conn,sid)
        if gpa:
            tk.Label(footer,text=f"GPA: {gpa['value']}   Rank: #{gpa.get('student_rank','—')}",
                     font=FONT_H3,bg=C["page"],fg=C["accent"]).pack(anchor="w",pady=(4,0))
        # ── Grade history tree fills remaining space ─────────────────
        cols=("Year","Semester","Subject","Q1","Q2","Mid","Final","Mark%","Grade")
        tf=tk.Frame(f,bg=C["page"]); tf.pack(fill="both",expand=True)
        tree=make_tree(tf,cols,heights=14)
        tree.column("Year",width=85); tree.column("Semester",width=65)
        tree.column("Subject",width=145); tree.column("Q1",width=38)
        tree.column("Q2",width=38); tree.column("Mid",width=42)
        tree.column("Final",width=52); tree.column("Mark%",width=62); tree.column("Grade",width=52)
        for r in logic.get_full_grade_history(self.conn,sid):
            fn=r.get("final_exam")
            fn_str="Pending" if (r.get("has_detail") and fn is None) else (str(fn) if fn is not None else "—")
            mark=r.get("pct")
            mark_str=str(mark) if mark is not None else ("Pending" if r.get("has_detail") else "—")
            tree.insert("","end",values=(
                r["year_name"],r.get("semester_name") or r.get("semester","—"),r["subject"],
                r.get("quiz1") or "—",r.get("quiz2") or "—",r.get("midterm") or "—",
                fn_str,mark_str,r.get("result_status") or r.get("status") or "—"))

    def page_attendance(self,p):
        page_title(p,"Attendance","Flagged students — below 75%")
        sems=logic.get_semesters_with_year(self.conn)
        if not sems:
            tk.Label(p,text="No semesters found.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        sem_opts={f"{s['name']} {s['year_name']} (ID:{s['semester_id']})":s["semester_id"]
                  for s in reversed(sems)}
        self._sem_var=tk.StringVar(value=list(sem_opts.keys())[0])
        row=tk.Frame(p,bg=C["page"]); row.pack(fill="x",pady=(0,12))
        ttk.Combobox(row,textvariable=self._sem_var,values=list(sem_opts.keys()),
                     font=FONT_BODY,state="readonly",width=32).pack(side="left",padx=(0,8))
        btn(row,"Load",lambda: self._load_flagged(sem_opts[self._sem_var.get()]),"ghost").pack(side="left")
        self._att_area=tk.Frame(p,bg=C["page"]); self._att_area.pack(fill="both",expand=True)
        self._load_flagged(list(sem_opts.values())[0])

    def _load_flagged(self,sem_id):
        clear(self._att_area)
        f=card(self._att_area); f.pack(fill="both",expand=True)
        cols=("ID","Name","Class","Days","Attended","Pct%")
        tree=make_tree(f,cols,heights=14)
        tree.column("ID",width=50); tree.column("Name",width=180)
        tree.column("Class",width=80); tree.column("Days",width=60)
        tree.column("Attended",width=70); tree.column("Pct%",width=70)
        for r in logic.get_low_attendance_students(self.conn,sem_id):
            tree.insert("","end",values=(
                r["student_id"],f"{r['f_name']} {r['l_name']}",
                f"{r['grade']}-{r['section']}",r["total_days"],r["attended"],f"{r['pct']}%"))

    def page_reports(self,p):
        page_title(p,"Reports","Class rankings by semester")
        classes=logic.get_all_classes(self.conn)
        cls_opts={f"Grade {c['grade']}-{c['section']}":c["class_id"] for c in classes}
        sems=logic.get_semesters_with_year(self.conn)
        sem_opts={f"{s['name']} {s['year_name']}":s["semester_id"] for s in reversed(sems)}
        ctrl=tk.Frame(p,bg=C["page"]); ctrl.pack(fill="x",pady=(0,12))
        self._rclass=tk.StringVar(value=list(cls_opts.keys())[0] if cls_opts else "")
        self._rsem=tk.StringVar(value=list(sem_opts.keys())[0] if sem_opts else "")
        ttk.Combobox(ctrl,textvariable=self._rclass,values=list(cls_opts.keys()),
                     font=FONT_BODY,state="readonly",width=20).pack(side="left",padx=(0,8))
        ttk.Combobox(ctrl,textvariable=self._rsem,values=list(sem_opts.keys()),
                     font=FONT_BODY,state="readonly",width=28).pack(side="left",padx=(0,8))
        btn(ctrl,"Load Ranking",
            lambda: self._load_ranking(cls_opts[self._rclass.get()],sem_opts[self._rsem.get()]),"ghost"
            ).pack(side="left")
        self._rep_area=tk.Frame(p,bg=C["page"]); self._rep_area.pack(fill="both",expand=True)

    def _load_ranking(self,class_id,sem_id):
        clear(self._rep_area)
        data=logic.get_class_ranking(self.conn,class_id,sem_id)
        if not data:
            tk.Label(self._rep_area,
                     text="No grade data for this semester yet. Finals may still be pending.",
                     font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(pady=20); return
        f=card(self._rep_area); f.pack(fill="both",expand=True)
        cols=("Rank","Name","Avg Mark","Standing")
        tree=make_tree(f,cols,heights=16)
        tree.column("Rank",width=60); tree.column("Name",width=220)
        tree.column("Avg Mark",width=100); tree.column("Standing",width=120)
        for i,r in enumerate(data,1):
            avg=r["avg_mark"]
            s="Excellent" if avg>=85 else "Very Good" if avg>=75 else \
              "Good" if avg>=65 else "Pass" if avg>=60 else "At Risk"
            tree.insert("","end",values=(i,f"{r['f_name']} {r['l_name']}",avg,s))

    def page_users(self,p):
        pass  # replaced by AdminContent.page_users monkey-patch below


# ════════════════════════════════════════════════════════════════
#  TEACHER CONTENT
# ════════════════════════════════════════════════════════════════

class TeacherContent(ContentArea):

    def page_dashboard(self,p):
        page_title(p,"My Dashboard","Your classes and subjects")
        tid=self.user["teacher_id"]; t=logic.get_teacher_by_id(self.conn,tid)
        info=card(p,padx=20,pady=16); info.pack(fill="x",pady=(0,16))
        tk.Label(info,text=f"{t['f_name']} {t['l_name']}",font=FONT_H2,bg=C["surface"],fg=C["ink"]).pack(anchor="w")
        tk.Label(info,text=t["email"],font=FONT_BODY,bg=C["surface"],fg=C["ink2"]).pack(anchor="w")
        sem=logic.get_active_semester(self.conn)
        if not sem:
            tk.Label(p,text="No active semester.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        subjects=logic.get_teacher_subjects(self.conn,tid,sem["semester_id"])
        tk.Label(p,text=f"Your subjects — {sem['name']} {sem['year_name']}",
                 font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(anchor="w",pady=(0,8))
        f=card(p); f.pack(fill="x")
        for s in subjects:
            row=tk.Frame(f,bg=C["surface"]); row.pack(fill="x",padx=16,pady=6)
            tk.Label(row,text=f"{s['name']}  —  Grade {s['grade']}-{s['section']}",
                     font=FONT_BODY,bg=C["surface"],fg=C["ink"]).pack(side="left")
            if s.get("enrolled_count"):
                tk.Label(row,text=f"{s['enrolled_count']} students",
                         font=FONT_SM,bg=C["surface"],fg=C["ink2"]).pack(side="right")

    def page_grades(self,p):
        page_title(p,"Enter Grades","Active semester — enter final exam marks to complete records")
        tid=self.user["teacher_id"]
        sem=logic.get_active_semester(self.conn)
        if not sem:
            tk.Label(p,text="No active semester.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        subjects=logic.get_teacher_subjects(self.conn,tid,sem["semester_id"])
        sub_opts={f"{s['name']} — Grade {s['grade']}-{s['section']}":s for s in subjects}
        self._sub_var=tk.StringVar(value=list(sub_opts.keys())[0] if sub_opts else "")
        row=tk.Frame(p,bg=C["page"]); row.pack(fill="x",pady=(0,6))
        ttk.Combobox(row,textvariable=self._sub_var,values=list(sub_opts.keys()),
                     font=FONT_BODY,state="readonly",width=40).pack(side="left",padx=(0,8))
        btn(row,"Load",
            lambda: self._load_grade_entry(sub_opts[self._sub_var.get()],sem["semester_id"]),"ghost"
            ).pack(side="left")
        tk.Label(p,
                 text=f"Semester: {sem['name']} {sem['year_name']}  ·  "
                      "Quiz & Midterm grades are pre-filled from seed data. Enter Final exam marks below.",
                 font=FONT_SM,bg=C["page"],fg=C["accent"]).pack(anchor="w",pady=(0,8))
        self._ge_area=tk.Frame(p,bg=C["page"]); self._ge_area.pack(fill="both",expand=True)

    def _load_grade_entry(self,subject,sem_id):
        clear(self._ge_area)
        class_id=subject.get("class_id")
        if not class_id:
            classes=logic.get_all_classes(self.conn)
            class_id=next((c["class_id"] for c in classes
                if c["grade"]==subject.get("grade") and c["section"]==subject.get("section")),None)
        if not class_id:
            tk.Label(self._ge_area,text="Class not found.",font=FONT_BODY,bg=C["page"],fg=C["danger"]).pack(); return
        is_pe=subject["name"]=="Physical Education"
        rows=logic.get_class_grade_details(self.conn,class_id,subject["subject_id"],sem_id)
        pending_count=sum(1 for r in rows if r.get("final_pending") and not is_pe)
        hdr=tk.Frame(self._ge_area,bg=C["page"]); hdr.pack(fill="x",pady=(0,4))
        tk.Label(hdr,text=f"{subject['name']} — Grade {subject.get('grade','?')}-{subject.get('section','?')}",
                 font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(side="left")
        if not is_pe:
            tk.Label(self._ge_area,
                     text="Quiz 1 /10  ·  Quiz 2 /10  ·  Midterm /20  ·  Final /60  →  Total /100  (pass = 60/100 = 60%)",
                     font=FONT_SM,bg=C["page"],fg=C["ink2"]).pack(anchor="w",pady=(0,2))
            if pending_count>0:
                tk.Label(self._ge_area,
                         text=f"⚠  {pending_count} student(s) need Final exam entry (shown in orange).",
                         font=FONT_SM,bg=C["page"],fg=C["warn"]).pack(anchor="w",pady=(0,4))
        f=card(self._ge_area,padx=8,pady=8); f.pack(fill="both",expand=True)
        hrow=tk.Frame(f,bg=C["surface"]); hrow.pack(fill="x",pady=(0,4))
        if is_pe:
            headers=[("Student",26),("Mark /100",10)]
        else:
            headers=[("Student",20),("Q1\n/10",6),("Q2\n/10",6),("Mid\n/20",6),
                     ("Final\n/60",7),("Total\n/100",7),("Status",8)]
        for col,w in headers:
            tk.Label(hrow,text=col,font=FONT_LABEL,bg=C["surface"],
                     fg=C["ink2"],width=w,justify="center").pack(side="left",padx=2)
        scr=scrollable(f); entries={}
        for r in rows:
            sid=r["student_id"]
            name_color=C["warn"] if (r.get("final_pending") and not is_pe) else C["ink"]
            rw=tk.Frame(scr,bg=C["surface"],highlightthickness=1,highlightbackground=C["border"])
            rw.pack(fill="x",pady=2)
            tk.Label(rw,text=f"{r['f_name']} {r['l_name']}",font=FONT_BODY,
                     bg=C["surface"],fg=name_color,width=20,anchor="w").pack(side="left",padx=6)
            if is_pe:
                cur_val=r.get("total","")
                var=tk.StringVar(value=str(cur_val) if cur_val else "")
                tk.Entry(rw,textvariable=var,font=FONT_BODY,bg=C["page"],fg=C["ink"],
                         relief="flat",highlightthickness=1,highlightbackground=C["border"],
                         width=8,insertbackground=C["ink"]).pack(side="left",padx=4,ipady=3)
                entries[sid]={"pe":var}
            else:
                vs={}
                for field,w_size,cur_v,bg_col in [
                    ("quiz1",6,r.get("quiz1"),C["page"]),
                    ("quiz2",6,r.get("quiz2"),C["page"]),
                    ("midterm",6,r.get("midterm"),C["page"]),
                    ("final_exam",7,r.get("final_exam"),C["accent2"])]:
                    var=tk.StringVar(value=str(cur_v) if cur_v is not None else "")
                    e=tk.Entry(rw,textvariable=var,font=FONT_BODY,
                               bg=bg_col,fg=C["ink"],relief="flat",
                               highlightthickness=1,highlightbackground=C["border"],
                               width=w_size,insertbackground=C["ink"])
                    e.pack(side="left",padx=2,ipady=3)
                    # Already-filled quiz/mid shown slightly dimmed
                    if field in ("quiz1","quiz2","midterm") and cur_v is not None:
                        e.configure(fg=C["ink2"])
                    vs[field]=var
                total_val=r.get("total")
                tk.Label(rw,text=str(total_val) if total_val is not None else "—",
                         font=FONT_BODY,bg=C["surface"],fg=C["ink"],width=7).pack(side="left",padx=2)
                if r.get("final_pending"):
                    st_text,st_col="Pending",C["warn"]
                elif total_val is not None:
                    pct=round(float(total_val),1)
                    st_text,st_col=("PASS",C["success"]) if pct>=60 else ("FAIL",C["danger"])
                else:
                    st_text,st_col="—",C["ink3"]
                tk.Label(rw,text=st_text,font=FONT_SM,bg=C["surface"],fg=st_col,width=8).pack(side="left",padx=2)
                entries[sid]=vs

        def save_all():
            saved,errors=0,[]
            for sid,vs in entries.items():
                try:
                    if "pe" in vs:
                        v=vs["pe"].get().strip()
                        if not v: continue
                        logic.save_grade(self.conn,sid,subject["subject_id"],sem_id,float(v))
                        saved+=1
                    else:
                        def fv(k):
                            v=vs[k].get().strip(); return float(v) if v else None
                        raw,pct,err=logic.save_grade_detail(
                            self.conn,sid,subject["subject_id"],sem_id,
                            fv("quiz1"),fv("quiz2"),fv("midterm"),fv("final_exam"))
                        if err: errors.append(f"Student {sid}: {err}")
                        else: saved+=1
                except Exception as ex: errors.append(f"ID {sid}: {ex}")
            msg=f"Saved {saved} records."
            if errors: msg+="\n\nErrors:\n"+"\n".join(errors[:5])
            messagebox.showinfo("Saved",msg)
            self._load_grade_entry(subject,sem_id)

        btn(self._ge_area,"Save All Grades",save_all).pack(anchor="e",pady=10)
        tk.Label(self._ge_area,
                 text="Orange = final not entered.  Blue column = Final /60.  Dimmed values already saved.",
                 font=FONT_SM,bg=C["page"],fg=C["ink3"]).pack(anchor="e")

    def page_attendance(self,p):
        page_title(p,"Attendance",f"Record attendance for {date.today()}")
        sem=logic.get_active_semester(self.conn)
        if not sem:
            tk.Label(p,text="No active semester.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        classes=logic.get_teacher_classes(self.conn,self.user["teacher_id"])
        if not classes:
            tk.Label(p,text="No classes assigned.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        cls_opts={f"Grade {c['grade']}-{c['section']}":c["class_id"] for c in classes}
        self._att_cls=tk.StringVar(value=list(cls_opts.keys())[0])
        row=tk.Frame(p,bg=C["page"]); row.pack(fill="x",pady=(0,12))
        ttk.Combobox(row,textvariable=self._att_cls,values=list(cls_opts.keys()),
                     font=FONT_BODY,state="readonly",width=20).pack(side="left",padx=(0,8))
        btn(row,"Load Class",
            lambda: self._load_att_form(cls_opts[self._att_cls.get()],sem["semester_id"]),"ghost"
            ).pack(side="left")
        self._att_form=tk.Frame(p,bg=C["page"]); self._att_form.pack(fill="both",expand=True)

    def _load_att_form(self,class_id,sem_id):
        clear(self._att_form)
        students=logic.get_students_by_class(self.conn,class_id); statuses={}
        f=card(self._att_form,padx=12,pady=12); f.pack(fill="both",expand=True)
        header=tk.Frame(f,bg=C["surface"]); header.pack(fill="x",pady=(0,8))
        for txt,w in [("Student",240),("Status",300)]:
            tk.Label(header,text=txt,font=FONT_LABEL,bg=C["surface"],
                     fg=C["ink2"],width=w//8).pack(side="left")
        scr=scrollable(f)
        for s in students:
            row2=tk.Frame(scr,bg=C["surface"],highlightthickness=1,highlightbackground=C["border"])
            row2.pack(fill="x",pady=2)
            tk.Label(row2,text=f"{s['f_name']} {s['l_name']}",font=FONT_BODY,
                     bg=C["surface"],fg=C["ink"],width=28,anchor="w").pack(side="left",padx=8)
            var=tk.StringVar(value="Present")
            for opt,col in [("Present",C["success"]),("Absent",C["danger"]),
                            ("Late",C["warn"]),("Excused",C["ink2"])]:
                tk.Radiobutton(row2,text=opt,variable=var,value=opt,font=FONT_SM,
                               bg=C["surface"],fg=col,activebackground=C["surface"],
                               selectcolor=C["surface"]).pack(side="left",padx=6)
            statuses[s["student_id"]]=var
        def submit():
            today=date.today()
            for sid,var in statuses.items():
                logic.save_attendance(self.conn,sid,today,var.get(),sem_id)
            messagebox.showinfo("Done",f"Attendance saved for {today}.")
        btn(self._att_form,"Submit Attendance",submit).pack(anchor="e",pady=12)


# ════════════════════════════════════════════════════════════════
#  STUDENT CONTENT
# ════════════════════════════════════════════════════════════════

class StudentContent(ContentArea):

    def _sid(self): return self.user.get("student_id")

    def _sem_badge(self,p):
        sem=logic.get_active_semester(self.conn)
        if sem:
            tk.Label(p,text=f"Active: {sem['name']} {sem['year_name']}",
                     font=FONT_SM,bg=C["page"],fg=C["accent"]).pack(anchor="e",pady=(0,4))

    def page_overview(self,p):
        sid=self._sid()
        if not sid:
            tk.Label(p,text="No student linked.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(); return
        s=logic.get_student_by_id(self.conn,sid)
        page_title(p,f"{s['f_name']} {s['l_name']}",f"Student Profile  ·  Grade {s['grade']}-{s['section']}")
        info=card(p,padx=20,pady=16); info.pack(fill="x",pady=(0,16))
        for i,(lbl,val) in enumerate([
            ("Student ID",s["student_id"]),("Gender",s["gender"]),("Birth Date",s["birth_date"]),
            ("Address",s["address"]),("Guardian",f"{s['g_fname']} {s['g_lname']}"),
            ("Phone",s["g_phone"]),("Status",s.get("status","active"))]):
            lbl_val(info,lbl,val,i)
        gpas=logic.get_all_gpas_for_student(self.conn,sid)
        if gpas:
            tk.Label(p,text="Academic GPA History",font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(anchor="w",pady=(12,8))
            gf=card(p,padx=16,pady=12); gf.pack(fill="x")
            rw=tk.Frame(gf,bg=C["surface"]); rw.pack(fill="x")
            for g in gpas:
                cf=tk.Frame(rw,bg=C["surface"],padx=14); cf.pack(side="left")
                tk.Label(cf,text=str(g["value"]),font=("Georgia",20,"bold"),bg=C["surface"],fg=C["accent"]).pack()
                tk.Label(cf,text=g["year_name"],font=FONT_SM,bg=C["surface"],fg=C["ink2"]).pack()
                if g.get("student_rank"):
                    tk.Label(cf,text=f"Rank #{g['student_rank']}",font=FONT_SM,bg=C["surface"],fg=C["ink3"]).pack()
        sem=logic.get_active_semester(self.conn)
        if sem:
            separator(p)
            tk.Label(p,text=f"Current Semester — {sem['name']} {sem['year_name']}",
                     font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(anchor="w",pady=(0,6))
            att=logic.get_attendance_summary(self.conn,sid,sem["semester_id"])
            att_col=C["danger"] if att["flagged"] else C["success"]
            ar=tk.Frame(p,bg=C["page"]); ar.pack(anchor="w")
            tk.Label(ar,text="Attendance: ",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(side="left")
            tk.Label(ar,text=f"{att['percentage']}%",font=FONT_H3,bg=C["page"],fg=att_col).pack(side="left")
            if att["flagged"]:
                tk.Label(ar,text="  ⚠ Below 75%",font=FONT_SM,bg=C["page"],fg=C["danger"]).pack(side="left")

    def page_grades(self,p):
        sid=self._sid()
        if not sid: return
        s=logic.get_student_by_id(self.conn,sid)
        page_title(p,"My Grades",f"{s['f_name']} {s['l_name']}")
        self._sem_badge(p)

        # Get two most recent semesters only
        all_sems=logic.get_semesters_with_year(self.conn)
        if not all_sems:
            tk.Label(p,text="No semester data found.",font=FONT_BODY,
                     bg=C["page"],fg=C["ink2"]).pack(anchor="w"); return

        # Only show current and previous semester as report card buttons
        recent=list(reversed(all_sems))[:2]  # [current, previous]
        bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,8))
        for sm in recent:
            label=f"📄 {sm['name']} {sm['year_name']} Report Card"
            sid2=sm["semester_id"]
            btn(bar,label,lambda s=sid2: self._show_rc(sid,s),"ghost").pack(side="left",padx=(0,8))

        tk.Label(p,text="Full grade history:",
                 font=FONT_LABEL,bg=C["page"],fg=C["ink2"]).pack(anchor="w",pady=(0,4))

        self._grades_area=tk.Frame(p,bg=C["page"]); self._grades_area.pack(fill="both",expand=True)
        self._load_all_grades(sid)

    def _load_all_grades(self,sid):
        clear(self._grades_area)
        f=card(self._grades_area); f.pack(fill="both",expand=True)
        cols=("Year","Semester","Subject","Q1","Q2","Mid","Final","Mark%","Grade")
        tree=make_tree(f,cols,heights=16)
        tree.column("Year",width=90); tree.column("Semester",width=65)
        tree.column("Subject",width=155); tree.column("Q1",width=38)
        tree.column("Q2",width=38); tree.column("Mid",width=42)
        tree.column("Final",width=52); tree.column("Mark%",width=62); tree.column("Grade",width=52)
        for r in logic.get_full_grade_history(self.conn,sid):
            fn=r.get("final_exam")
            fn_str="Pending" if (r.get("has_detail") and fn is None) else (str(fn) if fn is not None else "—")
            mark=r.get("pct")
            mark_str=str(mark) if mark is not None else ("Pending" if r.get("has_detail") else "—")
            tree.insert("","end",values=(
                r["year_name"],r.get("semester_name") or r.get("semester","—"),r["subject"],
                r.get("quiz1") or "—",r.get("quiz2") or "—",r.get("midterm") or "—",
                fn_str,mark_str,r.get("result_status") or r.get("status") or "—"))

    def _show_rc(self,sid,sem_id):
        rc=logic.get_report_card(self.conn,sid,sem_id)
        if not rc["grades"]:
            messagebox.showinfo("No data","No grades found for this semester."); return
        s=rc["student"]; sem=rc["semester"]
        m=Modal(self,"Report Card",width=700,height=660); f=m.body
        active=logic.get_active_semester(self.conn)
        is_active=active and sem and active["semester_id"]==sem["semester_id"]
        if is_active:
            tk.Label(f,text="★  Active semester — finals pending. Marks shown after exam entry.",
                     font=FONT_SM,bg=C["page"],fg=C["accent"]).pack(anchor="w",pady=(0,4))
        hdr=card(f,padx=16,pady=12); hdr.pack(fill="x",pady=(0,8))
        tk.Label(hdr,text=f"{s['f_name']} {s['l_name']}",font=FONT_H2,bg=C["surface"],fg=C["ink"]).pack(anchor="w")
        sem_name=sem.get("name","") if sem else ""; year=sem.get("year_name","") if sem else ""
        tk.Label(hdr,text=f"Grade {s['grade']}-{s['section']}  ·  {sem_name} {year}",
                 font=FONT_BODY,bg=C["surface"],fg=C["ink2"]).pack(anchor="w")
        tf=tk.Frame(f,bg=C["page"]); tf.pack(fill="x",pady=(0,6))
        n_rows=max(5,min(len(rc["grades"]),9))
        if rc.get("has_detail"):
            tree=make_tree(tf,("Subject","Q1/10","Q2/10","Mid/20","Final/60","Total/100","Grade"),heights=n_rows)
            tree.column("Subject",width=140); tree.column("Q1/10",width=50)
            tree.column("Q2/10",width=50); tree.column("Mid/20",width=58)
            tree.column("Final/60",width=65); tree.column("Total/100",width=62); tree.column("Grade",width=55)
            for r in rc["grades"]:
                fn=r.get("final_exam")
                fn_str="Pending" if r.get("final_pending") else (str(fn) if fn is not None else "—")
                raw=r.get("raw_total"); raw_str=str(raw) if raw is not None else "Pending"
                tree.insert("","end",values=(
                    r["subject"],r.get("quiz1") or "—",r.get("quiz2") or "—",
                    r.get("midterm") or "—",fn_str,raw_str,r.get("letter_grade","—")))
            if rc.get("finals_pending"):
                tk.Label(f,text="⚠  Final exams pending — overall mark appears after entry.",
                         font=FONT_SM,bg=C["page"],fg=C["warn"]).pack(anchor="w",pady=(0,4))
        else:
            tree=make_tree(tf,("Subject","Teacher","Mark%","Grade"),heights=n_rows)
            tree.column("Subject",width=180); tree.column("Teacher",width=155)
            tree.column("Mark%",width=65); tree.column("Grade",width=60)
            for r in rc["grades"]:
                tree.insert("","end",values=(
                    r["subject"],r.get("teacher","—"),r.get("pct","—"),r.get("letter_grade","—")))
        sf=card(f,padx=16,pady=12); sf.pack(fill="x",pady=(0,4))
        sr=tk.Frame(sf,bg=C["surface"]); sr.pack(fill="x",pady=(0,4))
        avg_text=f"{rc['average']}%  ({rc['average_letter']})" if rc["average"] else "Pending"
        tk.Label(sr,text=f"Semester Average:  {avg_text}",font=FONT_H3,bg=C["surface"],fg=C["ink"]).pack(side="left")
        if rc.get("gpa"):
            tk.Label(sr,text=f"GPA: {rc['gpa']['value']}    Rank: #{rc['gpa']['student_rank']}",
                     font=FONT_H3,bg=C["surface"],fg=C["accent"]).pack(side="right",padx=12)
        att=rc["attendance"]
        att_col=C["danger"] if att["flagged"] else C["success"]
        ar=tk.Frame(sf,bg=C["surface"]); ar.pack(fill="x",pady=(2,0))
        tk.Label(ar,text=f"Attendance: {att['percentage']}%",font=FONT_H3,bg=C["surface"],fg=att_col).pack(side="left")
        tk.Label(ar,text=f"   Present:{att['Present']}  Absent:{att['Absent']}  Late:{att['Late']}  Excused:{att['Excused']}",
                 font=FONT_BODY,bg=C["surface"],fg=C["ink2"]).pack(side="left")
        if att["flagged"]:
            tk.Label(sf,text="⚠  Attendance below 75% — at risk",font=FONT_SM,bg=C["surface"],fg=C["danger"]).pack(anchor="w")
        # ── Export PDF button ──────────────────────────────────────────
        def _export():
            import os, datetime
            from tkinter import filedialog
            sname=f"{rc['student']['f_name']}_{rc['student']['l_name']}".replace(" ","_")
            sem_tag=(rc["semester"].get("name","") if rc["semester"] else "").replace(" ","_")
            default=f"ReportCard_{sname}_{sem_tag}.pdf"
            path=filedialog.asksaveasfilename(
                defaultextension=".pdf",
                filetypes=[("PDF files","*.pdf"),("All files","*.*")],
                initialfile=default,
                title="Save Report Card PDF")
            if not path: return
            try:
                logic.export_report_card_pdf(rc, path)
                messagebox.showinfo("Exported", f"PDF saved to:\n{path}")
            except Exception as ex:
                messagebox.showerror("Export failed", str(ex))
        exp_bar=tk.Frame(f,bg=C["page"]); exp_bar.pack(fill="x",pady=(10,0))
        btn(exp_bar,"⬇  Export PDF",_export,"primary").pack(side="right")

    def page_attendance(self,p):
        sid=self._sid()
        if not sid: return
        s=logic.get_student_by_id(self.conn,sid)
        page_title(p,"My Attendance",f"{s['f_name']} {s['l_name']}")
        self._sem_badge(p)
        sems=logic.get_semesters_with_year(self.conn)
        if not sems: return
        sem_opts={f"{sm['name']} {sm['year_name']}":sm["semester_id"] for sm in reversed(sems)}
        self._sem_var2=tk.StringVar(value=list(sem_opts.keys())[0])
        row=tk.Frame(p,bg=C["page"]); row.pack(fill="x",pady=(0,12))
        ttk.Combobox(row,textvariable=self._sem_var2,values=list(sem_opts.keys()),
                     font=FONT_BODY,state="readonly",width=28).pack(side="left",padx=(0,8))
        btn(row,"Load",lambda: self._load_att(sid,sem_opts[self._sem_var2.get()]),"ghost").pack(side="left")
        self._att_area=tk.Frame(p,bg=C["page"]); self._att_area.pack(fill="both",expand=True)
        active=logic.get_active_semester(self.conn)
        self._load_att(sid,active["semester_id"] if active else sems[-1]["semester_id"])

    def _load_att(self,sid,sem_id):
        clear(self._att_area)
        summary=logic.get_attendance_summary(self.conn,sid,sem_id)
        sr=tk.Frame(self._att_area,bg=C["page"]); sr.pack(fill="x",pady=(0,12))
        for lbl,key,col in [("Present","Present",C["success"]),("Absent","Absent",C["danger"]),
                            ("Late","Late",C["warn"]),("Excused","Excused",C["ink2"])]:
            stat_box(sr,lbl,summary[key],col).pack(side="left",padx=(0,10))
        pct_col=C["danger"] if summary["flagged"] else C["success"]
        stat_box(sr,"Attendance %",f"{summary['percentage']}%",pct_col).pack(side="left",padx=(0,10))
        if summary["flagged"]:
            warn=tk.Frame(self._att_area,bg="#FFF3F3",
                          highlightthickness=1,highlightbackground=C["danger"])
            warn.pack(fill="x",pady=(0,8))
            tk.Label(warn,text="⚠  Attendance below 75% — at risk of academic consequences.",
                     font=FONT_BODY,bg="#FFF3F3",fg=C["danger"],padx=16,pady=10).pack(anchor="w")

    def page_announcements(self,p):
        page_title(p,"Announcements","Notices from school and teachers")
        sid=self._sid(); uid=self.user["user_id"]; class_id=None
        if sid:
            s=logic.get_student_by_id(self.conn,sid)
            if s:
                for c in logic.get_all_classes(self.conn):
                    if c["grade"]==s["grade"] and c["section"]==s["section"]:
                        class_id=c["class_id"]; break
        anns=logic.get_announcements_for_user(self.conn,uid,"student",student_id=sid,class_id=class_id)
        if not anns:
            tk.Label(p,text="No announcements at this time.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(pady=20); return
        scr_f=card(p); scr_f.pack(fill="both",expand=True)
        scr=scrollable(scr_f)
        for a in anns:
            f=tk.Frame(scr,bg=C["surface"],highlightthickness=1,highlightbackground=C["border"])
            f.pack(fill="x",pady=4,padx=4)
            hrow=tk.Frame(f,bg=C["surface"]); hrow.pack(fill="x",padx=12,pady=(8,2))
            unread=C["accent"] if not a["is_read"] else C["ink"]
            tk.Label(hrow,text=a["title"],font=FONT_H3,bg=C["surface"],fg=unread).pack(side="left")
            tk.Label(hrow,text=str(a["created_at"])[:16],font=FONT_SM,bg=C["surface"],fg=C["ink2"]).pack(side="right")
            tk.Label(f,text=a["body"][:300]+("…" if len(a["body"])>300 else ""),
                     font=FONT_BODY,bg=C["surface"],fg=C["ink"],wraplength=680,justify="left",
                     padx=12,pady=(0,10)).pack(anchor="w")
            logic.mark_announcement_read(self.conn,a["announcement_id"],uid)


# ════════════════════════════════════════════════════════════════
#  ADMIN MONKEY-PATCHED PAGES
# ════════════════════════════════════════════════════════════════

def _admin_past_students(self,p):
    page_title(p,"Past Students","Graduated and withdrawn students")
    f=card(p); f.pack(fill="both",expand=True)
    cols=("ID","Name","Status","Last Class","Enrolled","GPA","Guardian","Phone")
    tree=make_tree(f,cols,heights=18)
    tree.column("ID",width=50); tree.column("Name",width=160); tree.column("Status",width=90)
    tree.column("Last Class",width=90); tree.column("Enrolled",width=70); tree.column("GPA",width=60)
    tree.column("Guardian",width=140); tree.column("Phone",width=120)
    for r in logic.get_past_students(self.conn):
        badge="🎓 Graduated" if r["status"]=="graduated" else "⚠ Withdrawn"
        tree.insert("","end",values=(
            r["student_id"],f"{r['f_name']} {r['l_name']}",badge,
            f"{r['last_grade']}-{r['last_section']}",r.get("enrollment_year","—"),
            r.get("final_gpa","—"),f"{r['guardian_fname']} {r['guardian_lname']}",r["phone_no"]))

AdminContent.page_past_students=_admin_past_students


def _admin_announcements(self,p):
    page_title(p,"Announcements","Send and manage school announcements")
    bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,12))
    btn(bar,"+ New Announcement",lambda: self._new_ann_modal()).pack(side="right")
    f=card(p); f.pack(fill="both",expand=True)
    self._antree=make_tree(f,("Date","Title","Sent To","Reads"),heights=16)
    self._antree.column("Date",width=130); self._antree.column("Title",width=260)
    self._antree.column("Sent To",width=120); self._antree.column("Reads",width=60)
    self._antree.bind("<Double-1>",self._view_ann); self._load_anns()

def _admin_load_anns(self):
    self._antree.delete(*self._antree.get_children())
    for r in logic.get_all_announcements(self.conn):
        target=r["target_type"].capitalize()
        if r.get("target_id"): target+=f" #{r['target_id']}"
        self._antree.insert("","end",iid=str(r["announcement_id"]),values=(
            str(r["created_at"])[:16],r["title"],target,r["read_count"]))

def _admin_view_ann(self,event):
    sel=self._antree.selection()
    if not sel: return
    aid=int(sel[0]); rows=logic.get_all_announcements(self.conn)
    r=next((x for x in rows if x["announcement_id"]==aid),None)
    if not r: return
    m=Modal(self,r["title"],width=560,height=380); f=m.body
    tk.Label(f,text=f"From: {r['sender']}  ·  {str(r['created_at'])[:16]}  ·  To: {r['target_type']}",
             font=FONT_SM,bg=C["page"],fg=C["ink2"]).pack(anchor="w",pady=(0,8))
    tk.Label(f,text=r["body"],font=FONT_BODY,bg=C["page"],fg=C["ink"],wraplength=480,justify="left").pack(anchor="w",pady=8)
    btn(f,"Delete",lambda: (logic.delete_announcement(self.conn,aid),m.destroy(),self._load_anns()),"danger").pack(anchor="w")

def _admin_new_ann_modal(self):
    classes=logic.get_all_classes(self.conn)
    cls_opts={f"Grade {c['grade']}-{c['section']}":c["class_id"] for c in classes}
    m=Modal(self,"New Announcement",width=540,height=560); f=m.body
    title_var=entry_field(f,"Title",0)
    tk.Label(f,text="Message",font=FONT_LABEL,bg=C["page"],fg=C["ink2"]).grid(row=2,column=0,sticky="w",pady=(8,2))
    body_txt=tk.Text(f,height=6,font=FONT_BODY,bg=C["surface"],fg=C["ink"],relief="flat",
                     highlightthickness=1,highlightbackground=C["border"],wrap="word")
    body_txt.grid(row=3,column=0,sticky="ew",pady=(0,8))
    target_opts=["All (everyone)","Students only","Teachers only","Specific class","Specific student"]
    target_var=combo_field(f,"Send to",4,target_opts,"All (everyone)")
    cls_var=combo_field(f,"Class (if specific class)",6,list(cls_opts.keys()),
                        list(cls_opts.keys())[0] if cls_opts else "")
    sid_var=entry_field(f,"Student ID (if specific student)",8)
    def send():
        title=title_var.get().strip(); body=body_txt.get("1.0","end").strip()
        if not title or not body: messagebox.showwarning("Missing","Fill in title and message."); return
        tv=target_var.get()
        tmap={"All (everyone)":"all","Students only":"students","Teachers only":"teachers",
              "Specific class":"class","Specific student":"student"}
        ttype=tmap.get(tv,"all"); tid_val=None
        if ttype=="class" and cls_var.get(): tid_val=cls_opts.get(cls_var.get())
        elif ttype=="student":
            v=sid_var.get().strip()
            if not v.isdigit(): messagebox.showwarning("Invalid","Enter a valid Student ID."); return
            tid_val=int(v)
        logic.send_announcement(self.conn,self.user["user_id"],title,body,ttype,tid_val)
        messagebox.showinfo("Sent","Announcement sent."); m.destroy(); self._load_anns()
    btn(f,"Send Announcement",send).grid(row=10,column=0,sticky="ew",pady=12)

AdminContent.page_announcements=_admin_announcements
AdminContent._load_anns=_admin_load_anns
AdminContent._view_ann=_admin_view_ann
AdminContent._new_ann_modal=_admin_new_ann_modal


def _admin_academic(self,p):
    page_title(p,"Academic Management","Add years, open semesters, and run end-of-year promotion")
    conn=self.conn
    # Wrap entire body in scrollable so nothing is cut off
    scr_wrap=tk.Frame(p,bg=C["page"]); scr_wrap.pack(fill="both",expand=True)
    p=scrollable(scr_wrap)
    sem=logic.get_active_semester(conn)
    if sem:
        inf=card(p,padx=20,pady=12); inf.pack(fill="x",pady=(0,16))
        rw=tk.Frame(inf,bg=C["surface"]); rw.pack(fill="x")
        tk.Label(rw,text="Active Semester:",font=FONT_LABEL,bg=C["surface"],fg=C["ink2"]).pack(side="left")
        tk.Label(rw,text=f"  {sem['name']} {sem['year_name']}",
                 font=FONT_H3,bg=C["surface"],fg=C["accent"]).pack(side="left")
        pending=logic.check_finals_pending(conn,sem["school_year_id"])
        col=C["danger"] if pending>0 else C["success"]
        tk.Label(rw,text=f"   Finals pending: {pending}",
                 font=FONT_BODY,bg=C["surface"],fg=col).pack(side="right",padx=12)
    separator(p)
    tk.Label(p,text="1.  Add New Academic Year",font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(anchor="w")
    tk.Label(p,text="Creates the year with Fall semester only.",font=FONT_SM,bg=C["page"],fg=C["ink2"]).pack(anchor="w",pady=(2,8))
    f1=card(p,padx=16,pady=12); f1.pack(fill="x",pady=(0,16))
    rw1=tk.Frame(f1,bg=C["surface"]); rw1.pack(fill="x")
    tk.Label(rw1,text="Year label:",font=FONT_LABEL,bg=C["surface"],fg=C["ink2"]).pack(side="left")
    yr_var=tk.StringVar()
    tk.Entry(rw1,textvariable=yr_var,font=FONT_BODY,bg=C["page"],fg=C["ink"],relief="flat",
             highlightthickness=1,highlightbackground=C["border"],width=14,
             insertbackground=C["ink"]).pack(side="left",ipady=5,padx=8)
    tk.Label(rw1,text="e.g. 2026-2027",font=FONT_SM,bg=C["surface"],fg=C["ink3"]).pack(side="left")
    def add_year():
        label=yr_var.get().strip()
        if not label or "-" not in label: messagebox.showwarning("Invalid","Enter a year like 2026-2027."); return
        _,_,msg=logic.add_academic_year(conn,label); messagebox.showinfo("Done",msg); yr_var.set("")
    btn(rw1,"Add Year + Fall",add_year,"ghost").pack(side="right",padx=8)
    separator(p)
    tk.Label(p,text="2.  Open Spring Semester",font=FONT_H3,bg=C["page"],fg=C["ink"]).pack(anchor="w")
    f2=card(p,padx=16,pady=12); f2.pack(fill="x",pady=(0,16))
    years=logic.get_academic_years(conn); yr_opts={a["year_name"]:a["school_year_id"] for a in years}
    rw2=tk.Frame(f2,bg=C["surface"]); rw2.pack(fill="x")
    tk.Label(rw2,text="Year:",font=FONT_LABEL,bg=C["surface"],fg=C["ink2"]).pack(side="left")
    yr2_var=tk.StringVar(value=list(yr_opts.keys())[0] if yr_opts else "")
    ttk.Combobox(rw2,textvariable=yr2_var,values=list(yr_opts.keys()),
                 font=FONT_BODY,state="readonly",width=14).pack(side="left",padx=8)
    def add_spring():
        if not yr2_var.get(): return
        _,msg=logic.add_spring_semester(conn,yr_opts[yr2_var.get()]); messagebox.showinfo("Done",msg)
    btn(rw2,"Add Spring Semester",add_spring,"ghost").pack(side="left",padx=8)
    separator(p)
    tk.Label(p,text="3.  End-of-Year Promotion",font=FONT_H3,bg=C["page"],fg=C["danger"]).pack(anchor="w")
    tk.Label(p,text="Run ONLY after ALL final exam grades are entered.\n"
             "• Per-subject pass = 60%  ·  Grade 12 passers → Graduated  ·  Failures repeat year",
             font=FONT_SM,bg=C["page"],fg=C["ink2"],justify="left").pack(anchor="w",pady=(2,8))
    f3=card(p,padx=16,pady=12); f3.pack(fill="x")
    rw3=tk.Frame(f3,bg=C["surface"]); rw3.pack(fill="x")
    tk.Label(rw3,text="Process year:",font=FONT_LABEL,bg=C["surface"],fg=C["ink2"]).pack(side="left")
    proc_var=tk.StringVar(value=list(yr_opts.keys())[0] if yr_opts else "")
    ttk.Combobox(rw3,textvariable=proc_var,values=list(yr_opts.keys()),
                 font=FONT_BODY,state="readonly",width=14).pack(side="left",padx=8)
    self._proc_area=tk.Frame(p,bg=C["page"]); self._proc_area.pack(fill="both",expand=True,pady=(12,0))
    def run_eoy():
        if not proc_var.get(): return
        yid=yr_opts[proc_var.get()]
        pending=logic.check_finals_pending(conn,yid)
        if pending>0:
            messagebox.showerror("Blocked",f"{pending} student(s) still missing final exam grades.\nAll finals must be entered first."); return
        if not messagebox.askyesno("Confirm","This permanently updates student statuses. Continue?"): return
        result=logic.process_end_of_year(conn,yid)
        if result.get("blocked"): messagebox.showerror("Blocked",result["reason"]); return
        self._show_eoy_result(result)
    btn(rw3,"Run End-of-Year Processing",run_eoy,"danger").pack(side="left",padx=8)

def _admin_eoy_result(self,result):
    clear(self._proc_area)
    summary=tk.Frame(self._proc_area,bg=C["page"]); summary.pack(fill="x",pady=(0,10))
    for label,lst,col in [("Promoted",result["promoted"],C["success"]),
                           ("Graduated",result["graduated"],C["accent"]),
                           ("Repeated",result["repeated"],C["danger"]),
                           ("No data",result["no_data"],C["warn"])]:
        stat_box(summary,label,len(lst),col).pack(side="left",padx=(0,10))
    if result["repeated"]:
        tk.Label(self._proc_area,text="Repeating Students",font=FONT_H3,bg=C["page"],fg=C["danger"]).pack(anchor="w",pady=(6,4))
        rf=card(self._proc_area); rf.pack(fill="x")
        tree2=make_tree(rf,("Name","Grade","Failed Subjects"),heights=min(len(result["repeated"]),8))
        tree2.column("Name",width=180); tree2.column("Grade",width=60); tree2.column("Failed Subjects",width=300)
        for s in result["repeated"]:
            tree2.insert("","end",values=(f"{s['f_name']} {s['l_name']}",s["grade"],", ".join(s.get("failed_subjects",[]))))
    messagebox.showinfo("Done",
        f"Promoted: {len(result['promoted'])}\nGraduated: {len(result['graduated'])}\n"
        f"Repeating: {len(result['repeated'])}\nNo data: {len(result['no_data'])}")

AdminContent.page_academic=_admin_academic
AdminContent._show_eoy_result=_admin_eoy_result


def _admin_users(self,p):
    page_title(p,"All Accounts & Passwords","Every login — username and plain-text password")
    tabs=tk.Frame(p,bg=C["page"]); tabs.pack(fill="x",pady=(0,12))
    area=tk.Frame(p,bg=C["page"]); area.pack(fill="both",expand=True)

    def show_all():
        clear(area)
        f=card(area); f.pack(fill="both",expand=True)
        cols=("ID","Username","Role","Linked To","Password")
        tree=make_tree(f,cols,heights=18)
        tree.column("ID",width=40); tree.column("Username",width=150)
        tree.column("Role",width=80); tree.column("Linked To",width=160)
        tree.column("Password",width=120)
        for r in logic.get_all_users(self.conn):
            tree.insert("","end",iid=str(r["user_id"]),values=(
                r["user_id"],r["user_name"],r["role"],
                r.get("linked_name","—"),r.get("plain_password","••••••")))
        def reset_pw(e):
            sel=tree.selection()
            if not sel: return
            uid=int(sel[0])
            if messagebox.askyesno("Reset Password","Reset this user's password?"):
                new_pw=logic.reset_user_password(self.conn,uid)
                messagebox.showinfo("Reset",f"New password: {new_pw}")
                show_all()
        tree.bind("<Double-1>",reset_pw)

    def show_creds():
        clear(area)
        f=card(area); f.pack(fill="both",expand=True)
        cols=("Name","Class","Username","Password")
        tree=make_tree(f,cols,heights=18)
        tree.column("Name",width=200); tree.column("Class",width=80)
        tree.column("Username",width=180); tree.column("Password",width=130)
        for r in logic.get_student_credentials(self.conn):
            tree.insert("","end",values=(
                f"{r['f_name']} {r['l_name']}",
                f"{r['grade']}-{r['section']}",
                r["user_name"],r.get("plain_password","—")))

    btn(tabs,"All Accounts",show_all,"ghost").pack(side="left",padx=(0,8))
    btn(tabs,"Student Credentials",show_creds,"ghost").pack(side="left")
    show_all()

AdminContent.page_users=_admin_users


def _teacher_announcements(self,p):
    page_title(p,"Announcements","School notices and class messages")
    tid=self.user["teacher_id"]; uid=self.user["user_id"]
    bar=tk.Frame(p,bg=C["page"]); bar.pack(fill="x",pady=(0,12))
    btn(bar,"+ Send to My Class",lambda: self._teacher_ann_modal(tid)).pack(side="right")
    anns=logic.get_announcements_for_user(self.conn,uid,"teacher",teacher_id=tid)
    if not anns:
        tk.Label(p,text="No announcements at this time.",font=FONT_BODY,bg=C["page"],fg=C["ink2"]).pack(pady=20); return
    scr_f=card(p); scr_f.pack(fill="both",expand=True)
    scr=scrollable(scr_f)
    for a in anns:
        f=tk.Frame(scr,bg=C["surface"],highlightthickness=1,highlightbackground=C["border"])
        f.pack(fill="x",pady=4,padx=4)
        hrow=tk.Frame(f,bg=C["surface"]); hrow.pack(fill="x",padx=12,pady=(8,2))
        unread=C["accent"] if not a["is_read"] else C["ink"]
        tk.Label(hrow,text=a["title"],font=FONT_H3,bg=C["surface"],fg=unread).pack(side="left")
        tk.Label(hrow,text=str(a["created_at"])[:16],font=FONT_SM,bg=C["surface"],fg=C["ink2"]).pack(side="right")
        tk.Label(f,text=a["body"][:300]+("…" if len(a["body"])>300 else ""),
                 font=FONT_BODY,bg=C["surface"],fg=C["ink"],wraplength=680,justify="left",padx=12,pady=(0,8)).pack(anchor="w")
        logic.mark_announcement_read(self.conn,a["announcement_id"],uid)

def _teacher_ann_modal(self,tid):
    classes=logic.get_teacher_classes(self.conn,tid)
    m=Modal(self,"Send Announcement",width=540,height=520); f=m.body
    cls_opts={f"Grade {c['grade']}-{c['section']}":c["class_id"] for c in classes}
    tvar=combo_field(f,"Send to",0,["Specific class","Specific student","All my classes"],"Specific class")
    cls_var=combo_field(f,"Class",2,list(cls_opts.keys()),list(cls_opts.keys())[0] if cls_opts else "")
    sid_var=entry_field(f,"Student ID (for specific student)",4)
    title_var=entry_field(f,"Title",6)
    tk.Label(f,text="Message",font=FONT_LABEL,bg=C["page"],fg=C["ink2"]).grid(row=8,column=0,sticky="w",pady=(8,2))
    body_txt=tk.Text(f,height=5,font=FONT_BODY,bg=C["surface"],fg=C["ink"],relief="flat",
                     highlightthickness=1,highlightbackground=C["border"],wrap="word")
    body_txt.grid(row=9,column=0,sticky="ew",pady=(0,8))
    def send():
        title=title_var.get().strip(); body=body_txt.get("1.0","end").strip()
        if not title or not body: messagebox.showwarning("Missing","Fill in title and message."); return
        tv=tvar.get()
        if tv=="Specific class":
            cid=cls_opts.get(cls_var.get())
            logic.send_announcement(self.conn,self.user["user_id"],title,body,"class",cid)
            messagebox.showinfo("Sent",f"Sent to {cls_var.get()}.")
        elif tv=="Specific student":
            v=sid_var.get().strip()
            if not v.isdigit(): messagebox.showwarning("Invalid","Enter a valid Student ID."); return
            logic.send_announcement(self.conn,self.user["user_id"],title,body,"student",int(v))
            messagebox.showinfo("Sent",f"Sent to student #{v}.")
        else:
            for cid in cls_opts.values():
                logic.send_announcement(self.conn,self.user["user_id"],title,body,"class",cid)
            messagebox.showinfo("Sent","Sent to all your classes.")
        m.destroy()
    btn(f,"Send",send).grid(row=10,column=0,sticky="ew",pady=12)

TeacherContent.page_announcements=_teacher_announcements
TeacherContent._teacher_ann_modal=_teacher_ann_modal





# ════════════════════════════════════════════════════════════════
#  ENROLLMENT MANAGEMENT PAGE
# ════════════════════════════════════════════════════════════════

def _admin_enrollment(self, p):
    page_title(p, "Enrollment Management",
               "Enroll students in subjects · Assign teachers · Update homeroom teachers")

    # ── Controls bar ──────────────────────────────────────────────
    ctrl = tk.Frame(p, bg=C["page"]); ctrl.pack(fill="x", pady=(0, 10))

    sems = logic.get_semesters_with_year(self.conn)
    if not sems:
        tk.Label(p, text="No semesters found.", font=FONT_BODY,
                 bg=C["page"], fg=C["ink2"]).pack(anchor="w"); return
    sem_opts = {f"{s['name']} {s['year_name']}": s["semester_id"] for s in reversed(sems)}

    classes = logic.get_all_classes(self.conn)
    class_opts = {f"Grade {c['grade']}-{c['section']}": c["class_id"] for c in classes}
    teachers_all = logic.get_all_teachers(self.conn)

    tk.Label(ctrl, text="Semester:", font=FONT_LABEL, bg=C["page"], fg=C["ink2"]).pack(side="left")
    sem_var = tk.StringVar(value=list(sem_opts.keys())[0])
    ttk.Combobox(ctrl, textvariable=sem_var, values=list(sem_opts.keys()),
                 font=FONT_BODY, state="readonly", width=22).pack(side="left", padx=(4, 14))

    tk.Label(ctrl, text="Class:", font=FONT_LABEL, bg=C["page"], fg=C["ink2"]).pack(side="left")
    cls_var = tk.StringVar(value=list(class_opts.keys())[0] if class_opts else "")
    ttk.Combobox(ctrl, textvariable=cls_var, values=list(class_opts.keys()),
                 font=FONT_BODY, state="readonly", width=16).pack(side="left", padx=(4, 14))

    btn(ctrl, "Load", lambda: _load(), "ghost").pack(side="left", padx=(0, 8))
    btn(ctrl, "Enroll All Students", lambda: _bulk_enroll(), "primary").pack(side="right")

    # ── Main area ────────────────────────────────────────────────
    area = tk.Frame(p, bg=C["page"]); area.pack(fill="both", expand=True)

    def _load():
        clear(area)
        sem_id = sem_opts.get(sem_var.get())
        cls_id = class_opts.get(cls_var.get())
        if not sem_id or not cls_id: return

        # ── Homeroom teacher editor ───────────────────────────────
        hr_frame = card(area, padx=16, pady=10); hr_frame.pack(fill="x", pady=(0, 10))
        cls_data = logic.get_class_by_id(self.conn, cls_id)
        hr_row = tk.Frame(hr_frame, bg=C["surface"]); hr_row.pack(fill="x")
        tk.Label(hr_row, text=f"Homeroom Teacher — Grade {cls_var.get()}:",
                 font=FONT_LABEL, bg=C["surface"], fg=C["ink2"]).pack(side="left")
        teacher_opts_list = [(f"{t['f_name']} {t['l_name']}", t["teacher_id"]) for t in teachers_all]
        teacher_name_opts = [x[0] for x in teacher_opts_list]
        teacher_id_map    = {x[0]: x[1] for x in teacher_opts_list}
        current_hr = f"{cls_data.get('f_name','')} {cls_data.get('l_name','')}".strip() if cls_data else ""
        hr_var = tk.StringVar(value=current_hr if current_hr in teacher_name_opts else (teacher_name_opts[0] if teacher_name_opts else ""))
        ttk.Combobox(hr_row, textvariable=hr_var, values=teacher_name_opts,
                     font=FONT_BODY, state="readonly", width=24).pack(side="left", padx=(8, 8))
        def _save_hr():
            tid = teacher_id_map.get(hr_var.get())
            if tid:
                logic.update_homeroom_teacher(self.conn, cls_id, tid)
                messagebox.showinfo("Saved", "Homeroom teacher updated.")
        btn(hr_row, "Save", _save_hr, "ghost").pack(side="left")

        # ── Subject / teacher assignment table ────────────────────
        tk.Label(area, text="Subjects & Teacher Assignments",
                 font=FONT_H3, bg=C["page"], fg=C["ink"]).pack(anchor="w", pady=(4, 4))
        f = card(area); f.pack(fill="both", expand=True)
        cols = ("Subject", "Assigned Teacher", "Enrolled Students", "Actions")
        tree_frame = tk.Frame(f, bg=C["surface"]); tree_frame.pack(fill="both", expand=True)
        tree = make_tree(tree_frame, ("Subject", "Assigned Teacher", "Enrolled"), heights=12)
        tree.column("Subject",          width=180)
        tree.column("Assigned Teacher", width=220)
        tree.column("Enrolled",         width=100)

        subjects = logic.get_all_subjects_for_semester(self.conn, sem_id)
        # Filter to subjects relevant to this class
        class_subjects = logic.get_subjects_by_class_semester(self.conn, cls_id, sem_id)
        class_sub_ids  = {r["subject_id"] for r in class_subjects}
        shown = [s for s in subjects if s["subject_id"] in class_sub_ids]

        for row in shown:
            tree.insert("", "end", iid=str(row["subject_id"]), values=(
                row["name"], row["teacher_name"], row["enrolled_students"]
            ))

        # Teacher reassignment panel below tree
        act_frame = tk.Frame(f, bg=C["surface"]); act_frame.pack(fill="x", pady=(6, 0))
        tk.Label(act_frame, text="Reassign teacher for selected subject:",
                 font=FONT_LABEL, bg=C["surface"], fg=C["ink2"]).pack(side="left")
        new_teacher_var = tk.StringVar(value=teacher_name_opts[0] if teacher_name_opts else "")
        ttk.Combobox(act_frame, textvariable=new_teacher_var, values=teacher_name_opts,
                     font=FONT_BODY, state="readonly", width=24).pack(side="left", padx=(8, 8))

        def _reassign():
            sel = tree.selection()
            if not sel:
                messagebox.showwarning("No selection", "Select a subject row first."); return
            sub_id = int(sel[0])
            tid = teacher_id_map.get(new_teacher_var.get())
            if tid:
                logic.assign_teacher_to_subject(self.conn, sub_id, tid)
                messagebox.showinfo("Saved", "Teacher assignment updated.")
                _load()
        btn(act_frame, "Reassign", _reassign, "ghost").pack(side="left")

    def _bulk_enroll():
        sem_id = sem_opts.get(sem_var.get())
        cls_id = class_opts.get(cls_var.get())
        if not sem_id or not cls_id: return
        count = logic.bulk_enroll_class(self.conn, cls_id, sem_id)
        if count > 0:
            messagebox.showinfo("Done", f"{count} new enrollment(s) created.")
        else:
            messagebox.showinfo("Up to date", "All students are already enrolled.")
        _load()

    _load()

AdminContent.page_enrollment = _admin_enrollment

# ════════════════════════════════════════════════════════════════
#  CHANGE PASSWORD PAGE  (admin / teacher / student)
# ════════════════════════════════════════════════════════════════

def _page_change_password(self, p):
    page_title(p, "Change Password", "Set a new password for your account")
    wrap = tk.Frame(p, bg=C["page"]); wrap.pack(anchor="center", pady=40)
    f = card(wrap, padx=32, pady=28); f.pack()

    tk.Label(f, text="Current password", font=FONT_LABEL,
             bg=C["surface"], fg=C["ink2"]).grid(row=0, column=0, sticky="w", pady=(0,2))
    old_var = tk.StringVar()
    tk.Entry(f, textvariable=old_var, show="•", font=FONT_BODY,
             bg=C["page"], fg=C["ink"], relief="flat",
             highlightthickness=1, highlightbackground=C["border"],
             insertbackground=C["ink"], width=30).grid(row=1, column=0, sticky="ew", ipady=7, pady=(0,14))

    tk.Label(f, text="New password", font=FONT_LABEL,
             bg=C["surface"], fg=C["ink2"]).grid(row=2, column=0, sticky="w", pady=(0,2))
    new_var = tk.StringVar()
    tk.Entry(f, textvariable=new_var, show="•", font=FONT_BODY,
             bg=C["page"], fg=C["ink"], relief="flat",
             highlightthickness=1, highlightbackground=C["border"],
             insertbackground=C["ink"], width=30).grid(row=3, column=0, sticky="ew", ipady=7, pady=(0,14))

    tk.Label(f, text="Confirm new password", font=FONT_LABEL,
             bg=C["surface"], fg=C["ink2"]).grid(row=4, column=0, sticky="w", pady=(0,2))
    conf_var = tk.StringVar()
    tk.Entry(f, textvariable=conf_var, show="•", font=FONT_BODY,
             bg=C["page"], fg=C["ink"], relief="flat",
             highlightthickness=1, highlightbackground=C["border"],
             insertbackground=C["ink"], width=30).grid(row=5, column=0, sticky="ew", ipady=7, pady=(0,20))

    msg_lbl = tk.Label(f, text="", font=FONT_SM, bg=C["surface"])
    msg_lbl.grid(row=6, column=0, sticky="w", pady=(0,8))

    def _save():
        old_pw  = old_var.get()
        new_pw  = new_var.get()
        conf_pw = conf_var.get()
        if not old_pw or not new_pw:
            msg_lbl.config(text="Please fill in all fields.", fg=C["danger"]); return
        if new_pw != conf_pw:
            msg_lbl.config(text="New passwords do not match.", fg=C["danger"]); return
        if len(new_pw) < 6:
            msg_lbl.config(text="Password must be at least 6 characters.", fg=C["danger"]); return
        ok, msg = logic.change_password(self.conn, self.user["user_id"], old_pw, new_pw)
        if ok:
            # Update session so old_pw still works until re-login
            msg_lbl.config(text="✅  Password changed successfully!", fg=C["success"])
            old_var.set(""); new_var.set(""); conf_var.set("")
        else:
            msg_lbl.config(text=f"❌  {msg}", fg=C["danger"])

    btn(f, "Save New Password", _save, "primary").grid(row=7, column=0, sticky="ew", ipady=4)
    f.columnconfigure(0, weight=1)

# Credentials viewer — plain Toplevel, NOT a nav page
def _show_credentials_window(conn, master):
    """Admin-only: open a separate window listing all usernames + passwords for testing."""
    win = tk.Toplevel(master)
    win.title("System Credentials (Admin Only)")
    win.geometry("700x520")
    win.configure(bg=C["page"])
    tk.Label(win, text="All Accounts & Passwords",
             font=FONT_H2, bg=C["page"], fg=C["ink"]).pack(anchor="w", padx=20, pady=(16,4))
    tk.Label(win, text="For testing only — share with no one.",
             font=FONT_SM, bg=C["page"], fg=C["danger"]).pack(anchor="w", padx=20, pady=(0,10))
    tabs = tk.Frame(win, bg=C["page"]); tabs.pack(fill="x", padx=20, pady=(0,8))
    area = tk.Frame(win, bg=C["page"]); area.pack(fill="both", expand=True, padx=20, pady=(0,16))

    def show_all():
        clear(area)
        f = card(area); f.pack(fill="both", expand=True)
        cols = ("ID","Username","Role","Linked To","Password")
        tree = make_tree(f, cols, heights=16)
        tree.column("ID",width=40); tree.column("Username",width=160)
        tree.column("Role",width=80); tree.column("Linked To",width=180); tree.column("Password",width=130)
        for r in logic.get_all_users(conn):
            tree.insert("","end", iid=str(r["user_id"]), values=(
                r["user_id"], r["user_name"], r["role"],
                r.get("linked_name","—"), r.get("plain_password","••••")))

    def show_students():
        clear(area)
        f = card(area); f.pack(fill="both", expand=True)
        cols = ("Name","Class","Username","Password")
        tree = make_tree(f, cols, heights=16)
        tree.column("Name",width=200); tree.column("Class",width=80)
        tree.column("Username",width=180); tree.column("Password",width=130)
        for r in logic.get_student_credentials(conn):
            tree.insert("","end", values=(
                f"{r['f_name']} {r['l_name']}", f"{r['grade']}-{r['section']}",
                r["user_name"], r.get("plain_password","—")))

    btn(tabs, "All Accounts",   show_all,      "ghost").pack(side="left", padx=(0,8))
    btn(tabs, "Students Only",  show_students, "ghost").pack(side="left")
    show_all()

# Patch page_change_password onto all content classes
AdminContent.page_change_password   = _page_change_password
TeacherContent.page_change_password = _page_change_password
StudentContent.page_change_password = _page_change_password

# ════════════════════════════════════════════════════════════════
#  AI DATA ASSISTANT PAGE
# ════════════════════════════════════════════════════════════════

def _admin_ai_assistant(self, p):
    page_title(p, "Data Assistant",
               "Ask questions about your school data — instant, no internet needed")

    # ── Quick buttons ────────────────────────────────────────────
    QUICK = [
        ("📋 School Overview",        "school overview statistics"),
        ("❌ Failing Students",        "show failing students"),
        ("🏆 Top 10 by GPA",          "top 10 students by GPA"),
        ("📉 Attendance Risk",         "students with attendance risk below 75"),
        ("📊 Average by Class",        "average by class"),
        ("📚 Average by Subject",      "average by subject"),
        ("👨‍🏫 Teachers & Subjects",    "show all teachers and their subjects"),
        ("⏳ Pending Finals",          "show pending finals"),
        ("🔴 Failing 2+ Subjects",     "students failing more than one subject"),
        ("📈 Most Improved",           "show top 10 most improved students"),
    ]
    qbar_outer = tk.Frame(p, bg=C["page"]); qbar_outer.pack(fill="x", pady=(0, 8))
    tk.Label(qbar_outer, text="Quick questions:", font=FONT_LABEL,
             bg=C["page"], fg=C["ink2"]).pack(anchor="w", pady=(0, 4))
    qbar = tk.Frame(qbar_outer, bg=C["page"]); qbar.pack(fill="x")
    row1 = tk.Frame(qbar, bg=C["page"]); row1.pack(fill="x", pady=(0, 3))
    row2 = tk.Frame(qbar, bg=C["page"]); row2.pack(fill="x")
    for i, (label, question) in enumerate(QUICK):
        tk.Button((row1 if i < 5 else row2), text=label, font=FONT_SM,
                  bg=C["accent2"], fg=C["accent"], relief="flat", cursor="hand2",
                  padx=10, pady=4,
                  command=lambda q=question: _ask(q)
                  ).pack(side="left", padx=(0, 6))

    # ── Chat history ─────────────────────────────────────────────
    hist_frame = card(p); hist_frame.pack(fill="both", expand=True, pady=(0, 10))
    h_canvas = tk.Canvas(hist_frame, bg=C["surface"], highlightthickness=0)
    h_sb = ttk.Scrollbar(hist_frame, orient="vertical", command=h_canvas.yview)
    chat_inner = tk.Frame(h_canvas, bg=C["surface"])
    chat_inner.bind("<Configure>",
        lambda e: h_canvas.configure(scrollregion=h_canvas.bbox("all")))
    h_canvas.create_window((0, 0), window=chat_inner, anchor="nw")
    h_canvas.configure(yscrollcommand=h_sb.set)
    h_canvas.pack(side="left", fill="both", expand=True)
    h_sb.pack(side="right", fill="y")

    def _scroll_bottom():
        h_canvas.update_idletasks(); h_canvas.yview_moveto(1.0)

    def _add_bubble(text, is_user=True, color=None):
        row = tk.Frame(chat_inner, bg=C["surface"], pady=3)
        row.pack(fill="x", padx=12)
        align = "e" if is_user else "w"
        bg = C["accent"] if is_user else C["accent2"]
        fg = C["surface"] if is_user else C["ink"]
        if color: bg = color; fg = C["surface"]
        tk.Label(row, text=text, font=FONT_BODY, bg=bg, fg=fg,
                 wraplength=640, justify="left", anchor="w",
                 padx=12, pady=7).pack(anchor=align)
        _scroll_bottom()
        return row

    def _add_table(columns, rows):
        wrap = tk.Frame(chat_inner, bg=C["surface"], pady=4)
        wrap.pack(fill="x", padx=12)
        show_cols = columns[:8]
        tree = make_tree(wrap, show_cols, heights=min(len(rows), 10))
        col_w = max(80, min(180, 700 // max(len(show_cols), 1)))
        for c in show_cols:
            tree.column(c, width=col_w, anchor="w")
        for r in rows[:100]:
            vals = [str(r.get(c,"")) if r.get(c) is not None else "—" for c in show_cols]
            tree.insert("", "end", values=vals)
        if len(rows) > 100:
            tk.Label(wrap, text=f"  … {len(rows)-100} more rows not shown",
                     font=FONT_SM, bg=C["surface"], fg=C["ink3"]).pack(anchor="w")
        _scroll_bottom()

    _add_bubble(
        "👋  Hello! Ask me anything about your school data.\n\n"
        "You can write naturally, for example:\n"
        "• How many students are in grade 10?\n"
        "• Show failing students in grade 11 section A\n"
        "• Top 5 students by GPA in grade 9\n"
        "• Average math grade in grade 10\n"
        "• How many female students are in grade 8?\n"
        "• Show students with attendance below 70%\n"
        "• Which students failed science this semester?",
        is_user=False)

    # ── Input bar ────────────────────────────────────────────────
    input_row = tk.Frame(p, bg=C["page"]); input_row.pack(fill="x")
    inp_var = tk.StringVar()
    inp = tk.Entry(input_row, textvariable=inp_var, font=FONT_BODY,
                   bg=C["surface"], fg=C["ink"], relief="flat",
                   highlightthickness=1, highlightbackground=C["border"],
                   highlightcolor=C["accent"], insertbackground=C["ink"])
    inp.pack(side="left", fill="x", expand=True, ipady=9, padx=(0, 10))
    inp.focus()
    btn(input_row, "Ask  ➤", lambda: _ask(inp_var.get()), "primary").pack(side="left")
    inp.bind("<Return>", lambda e: _ask(inp_var.get()))

    def _ask(question):
        question = question.strip()
        if not question: return
        inp_var.set("")
        _add_bubble(question, is_user=True)

        role   = self.user.get("role", "admin")
        tid    = self.user.get("teacher_id")
        result = logic.run_query_assistant(self.conn, question, role=role, teacher_id=tid)

        if not result["matched"]:
            _add_bubble(
                "I didn't understand that. Try phrasing like:\n"
                "• 'How many students in grade 10?'\n"
                "• 'Show failing students in grade 11 section A'\n"
                "• 'Top 5 students by GPA'\n"
                "• 'Average math grade in grade 10'\n"
                "• 'Students with attendance below 75%'\n"
                "• 'How many female students in grade 8?'\n"
                "Or click a quick button above.",
                is_user=False, color=C["warn"])
            return

        if result.get("error"):
            _add_bubble(f"❌  {result['error']}", is_user=False, color=C["danger"])
            return

        summary = result.get("summary","")
        if summary:
            _add_bubble(f"✅  {summary}", is_user=False, color=C["success"])
        if result.get("rows"):
            _add_table(result["columns"], result["rows"])
        elif not result.get("error") and not summary:
            _add_bubble("No data found.", is_user=False)


AdminContent.page_ai_assistant = _admin_ai_assistant
TeacherContent.page_ai_assistant = _admin_ai_assistant

# ════════════════════════════════════════════════════════════════
#  MAIN APPLICATION
# ════════════════════════════════════════════════════════════════

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("SIMS — School Information Management System")
        self.geometry("1200x750")
        self.minsize(900,600)
        self.configure(bg=C["page"])
        self._show_login()

    def _show_login(self):
        for w in self.winfo_children(): w.destroy()
        LoginScreen(self,self._on_login).pack(fill="both",expand=True)

    def _on_login(self,user):
        for w in self.winfo_children(): w.destroy()
        role=user["role"]
        if role=="admin":
            items=[("Dashboard","dashboard"),("🤖 Data Assistant","ai_assistant"),
                   ("Students","students"),("Past Students","past_students"),
                   ("Teachers","teachers"),("Classes","classes"),("Grades","grades"),
                   ("Enrollment","enrollment"),
                   ("Attendance","attendance"),("Reports","reports"),
                   ("Announcements","announcements"),("Academic Mgmt","academic"),
                   ("🔒 Change Password","change_password")]
            content_cls=AdminContent
        elif role=="teacher":
            items=[("Dashboard","dashboard"),("Grades","grades"),
                   ("Attendance","attendance"),("Announcements","announcements"),
                   ("🤖 AI Assistant","ai_assistant"),
                   ("🔒 Change Password","change_password")]
            content_cls=TeacherContent
        else:
            items=[("My Profile","overview"),("My Grades","grades"),
                   ("Attendance","attendance"),("Announcements","announcements"),
                   ("🔒 Change Password","change_password")]
            content_cls=StudentContent
        container=tk.Frame(self,bg=C["page"])
        container.pack(fill="both",expand=True)
        content=content_cls(container,user)
        content.pack(side="right",fill="both",expand=True)
        sidebar=Sidebar(container,items,lambda key: content.show(key),
                        user["user_name"],role,self._show_login)
        sidebar.pack(side="left",fill="y")
        sidebar.select_first()

if __name__=="__main__":
    app=App()
    app.mainloop()