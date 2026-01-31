import json
import asyncio
from js import document, window, console

dynamic_value_pool = [] 
selected_values = set()

async def startup():
    await asyncio.sleep(0.5) 
    try:
        with open("config.json", "r") as f:
            config = json.load(f)
        
        window.initSupabase(config["SB_URL"], config["SB_KEY"])
        document.getElementById("status").innerText = "SYSTEM ONLINE"
    except Exception as e:
        console.error(f"Startup Error: {e}")
        document.getElementById("status").innerText = "OFFLINE: CONFIG ERROR"

asyncio.ensure_future(startup())

async def handle_login(event):
    status = document.getElementById("status")
    email = document.getElementById("email").value.strip()
    password = document.getElementById("password").value.strip()

    status.innerText = "AUTHENTICATING..."
    res = await window.authHelper.signIn(email, password)

    if res.error:
        status.innerText = "ACCESS DENIED"
        window.alert(f"Error: {res.error.message}")
    else:
        status.innerText = "IDENTITY VERIFIED"
        # Start the cinematic transition
        await run_transition_sequence()

async def handle_signup(event):
    status = document.getElementById("status")
    email = document.getElementById("email").value.strip()
    password = document.getElementById("password").value.strip()
    
    status.innerText = "FORGING IDENTITY..."
    res = await window.authHelper.signUp(email, password)
    
    if res.error:
        window.alert(f"Signup Error: {res.error.message}")
    else:
        window.alert("Identity Created. You may now Sign In.")

async def run_transition_sequence():
    """Choreographs transition and fetches live data."""
    # 1. Hide Login
    gate = document.getElementById("auth-gate")
    gate.classList.add("opacity-0", "scale-95")
    
    # NEW: Fetch values while the animation plays
    status = document.getElementById("status")
    status.innerText = "SYNCING CONSTELLATION..."
    
    res = await window.authHelper.fetchValues()
    
    if res.error:
        console.error(f"Data Fetch Error: {res.error.message}")
        # Fallback to a few defaults if DB fails
        global dynamic_value_pool
        dynamic_value_pool = [{"value_name": "Cabbages"}, {"value_name": "Purpose"}]
    else:
        # Convert JS Proxy/List to Python List
        dynamic_value_pool = res.data.to_py()
        status.innerText = "SYSTEM ONLINE"

    await asyncio.sleep(0.7)
    gate.classList.add("hidden")

    # 2. Show Intro Text
    stage = document.getElementById("intro-stage")
    text = document.getElementById("intro-text")
    stage.classList.remove("hidden")
    await asyncio.sleep(0.1)
    text.classList.remove("opacity-0", "translate-y-8")
    
    # 3. Hold and Fade Out Intro
    await asyncio.sleep(2.5)
    text.classList.add("opacity-0", "-translate-y-12")
    await asyncio.sleep(0.8)
    stage.classList.add("hidden")

    # 4. Reveal Constellation
    view = document.getElementById("constellation-view")
    view.classList.remove("hidden")
    render_constellation() # Now uses dynamic_value_pool
    await asyncio.sleep(0.1)
    view.classList.remove("opacity-0")

def render_constellation():
    cloud = document.getElementById("values-cloud")
    cloud.innerHTML = ""
    
    # Shuffle or slice if you want a random subset
    for i, item in enumerate(dynamic_value_pool):
        val = item['value_name']
        cat = item['value_categories']['name']
        
        btn = document.createElement("button")
        
        # Style based on Category or Index
        weight = "font-black text-xl" if i % 4 == 0 else "font-medium text-sm"
        
        # Color coding by category (Tailwind classes)
        cat_colors = {
            "Strength": "hover:text-red-400 hover:border-red-400",
            "Intelligence": "hover:text-blue-400 hover:border-blue-400",
            "Integrity": "hover:text-green-400 hover:border-green-400"
        }
        accent = cat_colors.get(cat, "hover:text-amber-500 hover:border-amber-500")

        btn.className = f"value-node transition-all duration-500 px-6 py-3 rounded-full border border-zinc-900 bg-zinc-900/30 {accent} {weight}"
        btn.style.animationDelay = f"{i * 0.1}s"
        btn.innerText = val
        btn.title = f"Category: {cat}" # Shows category on hover
        btn.onclick = lambda e, v=val: toggle_value(v)
        
        cloud.appendChild(btn)

def toggle_value(val):
    btn_list = document.querySelectorAll(".value-node")
    target_btn = next((b for b in btn_list if b.innerText == val), None)

    if val in selected_values:
        selected_values.remove(val)
        if target_btn:
            target_btn.classList.remove("border-amber-500", "text-amber-500", "bg-amber-600/10")
            target_btn.classList.add("border-zinc-900", "bg-zinc-900/30")
    elif len(selected_values) < 5:
        selected_values.add(val)
        if target_btn:
            target_btn.classList.add("border-amber-500", "text-amber-500", "bg-amber-600/10")
            target_btn.classList.remove("border-zinc-900", "bg-zinc-900/30")
    
    document.getElementById("selection-counter").innerText = f"{len(selected_values)} / 5 Selected"
