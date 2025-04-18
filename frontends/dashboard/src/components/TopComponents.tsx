import { createEffect, createSignal, Show } from "solid-js";
import { useTrieve } from "../hooks/useTrieve";
import { MagicSuspense } from "./MagicBox";
import { createToast } from "./ShowToasts";
import { TbReload } from "solid-icons/tb";
import { useContext } from "solid-js";
import { UserContext } from "../contexts/UserContext";

interface TopComponent {
  component_name: string;
  count: number;
}

interface TopComponentsProps {
  orgId: string;
}

export const TopComponents = (props: TopComponentsProps) => {
  const { orgId } = props;
  const userContext = useContext(UserContext);
  const trieve = useTrieve();
  const [topComponents, setTopComponents] = createSignal<TopComponent[]>([]);
  const [loading, setLoading] = createSignal(false);

  const fetchTopComponents = async () => {
    try {
      setLoading(true);
      const response = await trieve.fetch("/api/analytics/events/component", "post", {
        data: {
          type: "top_components",
          page: 1
        },
        datasetId: userContext.selectedOrg().dataset_ids[0] || "",
      });

      if (response && response.top_components) {
        setTopComponents(response.top_components);
      }
    } catch (error) {
      console.error("Error fetching top components:", error);
      createToast({
        title: "Error",
        type: "error",
        message: "Failed to fetch top components data",
      });
    } finally {
      setLoading(false);
    }
  };

  createEffect(() => {
    if (orgId) {
      void fetchTopComponents();
    }
  });

  return (
    <div class="py-6">
      <div class="flex items-end justify-between pb-4">
        <div>
          <h2 class="text-lg font-medium text-neutral-900">Top Components by Interactions</h2>
          <p class="text-sm text-neutral-600">
            Components with the most user interactions
          </p>
        </div>
        <button
          onClick={() => fetchTopComponents()}
          class="flex items-center space-x-1 text-sm text-fuchsia-600 hover:text-fuchsia-500"
          disabled={loading()}
        >
          <TbReload class={loading() ? "animate-spin" : ""} />
          <span>Refresh</span>
        </button>
      </div>

      <MagicSuspense>
        <Show
          when={topComponents().length > 0}
          fallback={
            <div class="py-4 text-center text-sm text-neutral-500">
              No component interaction data available
            </div>
          }
        >
          <div class="overflow-hidden rounded-lg border border-neutral-200 bg-white">
            <table class="min-w-full divide-y divide-neutral-200">
              <thead class="bg-neutral-100">
                <tr>
                  <th
                    scope="col"
                    class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-neutral-500"
                  >
                    Component Name
                  </th>
                  <th
                    scope="col"
                    class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-neutral-500"
                  >
                    Interactions
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-neutral-200 bg-white">
                {topComponents().map((component) => (
                  <tr class="hover:bg-neutral-50">
                    <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-neutral-900">
                      {component.component_name}
                    </td>
                    <td class="whitespace-nowrap px-6 py-4 text-sm text-neutral-500">
                      {component.count}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Show>
      </MagicSuspense>
    </div>
  );
};