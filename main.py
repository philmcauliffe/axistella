import json
import asyncio
from js import document, window, console

# Force rebuild
global dynamic_value_pool
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
    
    status = document.getElementById("status")
    status.innerText = "SYNCING CONSTELLATION..."
    
    res = await window.authHelper.fetchValues()
    if res.data:
        # Convert to Python list of strings
        raw_data = res.data.to_py()
        all_names = [item['value_name'] for item in raw_data]
        
        # 2. Pick 30 random values from your database
        if len(all_names) > 15:
            dynamic_value_pool = random.sample(all_names, 15)
        else:
            dynamic_value_pool = all_names
            random.shuffle(dynamic_value_pool)
            status.innerText = "SYSTEM ONLINE"
    else:
        console.error("Fetch failed or returned no data")
    
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
    render_constellation()
    await asyncio.sleep(0.1)
    view.classList.remove("opacity-0")

def render_constellation():
    cloud = document.getElementById("values-cloud")
    cloud.innerHTML = ""
    
    for i, val in enumerate(dynamic_value_pool):
        btn = document.createElement("button")
        
        # Keep the visual variety
        weight = "font-black text-xl" if i % 3 == 0 else "font-medium text-sm"
        
        btn.className = f"value-node transition-all duration-500 px-6 py-3 rounded-full border border-zinc-900 bg-zinc-900/30 hover:border-amber-500 hover:text-amber-500 {weight}"
        btn.style.animationDelay = f"{i * 0.1}s"
        btn.innerText = val
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
